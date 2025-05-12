class PostSearchService
  def initialize(params)
    @ransack_fields = params[:q]
    @access_type = params[:access_type]
    @sorted_by = params[:sorted_by]
    @subject = params[:subject]
    @problem = params[:problem]
    @idea = params[:idea]
    @location_tags = params[:location_tags]
    @resource_tags = params[:resource_tags]
    @post_type = params[:post_type] || ''
    @subject_id = params[:subject_id]
    @problem_id = params[:problem_id]
    @tree_number = params[:tree_number]
    @include_mastodon = params[:include_mastodon] == '1'
    @include_lemmy = params[:include_lemmy] == '1'
    @include_reddit = params[:include_reddit] == '1'
    @include_bluesky = params[:include_bluesky] == '1'
    @include_peer = params[:include_peer] == '1'
  end

  attr_accessor :ransack_fields, :access_type, :sorted_by, :post_type, :subject,
                :problem, :idea, :resource_tags, :location_tags,
                :subject_id, :problem_id, :tree_number,
                :include_mastodon, :include_lemmy, :include_reddit, :include_bluesky, :include_peer

  def filter
    ransack_fields = @ransack_fields.merge(post_type_eq: post_type)
    if tree_number.present?
      root_post = Post.find_by(id: tree_number)
      if root_post
        # Get all posts in the tree (subject and its problems and ideas)
        tree_posts = case root_post.post_type
        when Post::POST_TYPE_SUBJECT
          [root_post] + root_post.child_posts + root_post.child_posts.map(&:ideas).flatten
        when Post::POST_TYPE_PROBLEM
          [root_post.parent_subject, root_post] + root_post.ideas
        when Post::POST_TYPE_IDEA
          [root_post.problem.parent_subject, root_post.problem, root_post]
        end

        posts = Post.where(id: tree_posts.compact.map(&:id))
        posts = posts_with_access(access_type, posts) if access_type.present?
        posts = sort_posts(sorted_by, posts) if sorted_by.present?
        return posts
      end
    end

    if post_type.in?(%w[idea problem]) && (subject.present? || problem.present?) && subject_id.nil? && problem_id.nil?
      case post_type
      when Post::POST_TYPE_PROBLEM
        if subject.present?
          ransack_fields = ransack_fields.merge(parent_subject_title_eq: @subject)
        elsif @problem.present?
          ransack_fields = ransack_fields.merge(title_eq: @problem)
        end
      when Post::POST_TYPE_IDEA
        if @problem.present? && subject.present? && @idea.nil?
          ransack_fields = ransack_fields.merge(problem_title_eq: @problem, subject_title_eq: subject)
        elsif @problem.present? && subject.present? && @idea.present?
          ransack_fields = ransack_fields.merge(problem_title_eq: @problem, subject_title_eq: subject, idea_title_eq: @idea)
        else
          ransack_fields = ransack_fields.merge(problem_title_eq: @problem) if @problem.present?
        end
        ransack_fields = ransack_fields.merge(problem_title_eq: @problem, subject_title_eq: subject) if @problem.present? && subject.present?
      end
      q = Post.ransack(ransack_fields)
      posts = q.result(distinct: true)
    else
      if subject_id.present? || problem_id.present?

        if subject_id.present?
          post = Post.find(subject_id)
          posts = post.child_posts.where(post_type: post_type)
          posts = posts_with_access(access_type, posts)
          posts = sort_posts(sorted_by, posts)
          return posts
        end

        if problem_id.present?
          problem = Post.find(problem_id)
          posts = problem.ideas.where(post_type: post_type)
          posts = posts_with_access(access_type, posts)
          posts = sort_posts(sorted_by, posts)
          return posts
        end
      end

      if subject.present?
        ransack_fields[:title_cont] = subject
        ransack_fields[:post_type_eq] = Post::POST_TYPE_SUBJECT
      end

      if problem.present?
        ransack_fields[:title_cont] = problem
        ransack_fields[:post_type_eq] = Post::POST_TYPE_PROBLEM
      end

      if idea.present?
        ransack_fields[:title_cont] = idea
        ransack_fields[:post_type_eq] = Post::POST_TYPE_IDEA
      end

      q = Post.ransack(ransack_fields)

      posts = q.result(distinct: true)

    end
    if access_type.present?
      posts = posts_with_access(access_type, posts)
    end

    if sorted_by.present?
      posts = sort_posts(sorted_by, posts)
    end

    if resource_tags.present?
      posts = Post.tagged_with([resource_tags]).where(id: posts.pluck(:id))
    end

    if location_tags.present?
      posts = Post.tagged_with(location_tags, on: :tags).where(id: posts.pluck(:id))
    end

    if post_type == Post::POST_TYPE_WIKI_POSTS_ONLY || post_type == ''
      posts = posts.where(post_type: Post::CORE_POST_TYPES)
    elsif post_type == 'All'
      posts
    elsif post_type == Post::POST_TYPE_IDEA && subject.present? && @idea.nil?
      posts = posts.collect(&:child_posts).flatten.uniq.collect(&:ideas).uniq.flatten
    elsif post_type == Post::POST_TYPE_IDEA && subject.present? && @idea.present?
      q = posts
      posts = q.ransack(title_cont: @idea).result(distinct: true)
    else
      post_ids = posts&.map(&:id)
      posts = Post.where(id: post_ids, post_type: post_type)
    end

    should_include_fediverse = include_mastodon || include_lemmy || include_reddit || include_bluesky || include_peer
    
    if should_include_fediverse && @ransack_fields && @ransack_fields[:title_cont].present?
      posts = merge_with_federated_content(posts, @ransack_fields[:title_cont])
    end

    posts
  end

  private

  def posts_with_access(access_type, posts)
    if access_type == 'Public'
      post_ids = posts&.map(&:id)
      posts = Post.where(id: post_ids, private: false)
    elsif access_type == 'Curated'
      posts = posts.where(curated: true)
    end
    posts
  end

  def sort_posts(sorted_by, posts)
    if sorted_by == 'Highest Rated' || sorted_by == 'Highest Rated/View'
      posts = Post.joins('LEFT JOIN likes ON likes.likeable_id = posts.id').group('likes.likeable_id, posts.id').order('count(posts.id) DESC').where(id: posts.ids)
    elsif sorted_by == 'New'
      posts = posts.order('posts.created_at DESC')
    else
    end

    posts
  end

  def merge_with_federated_content(regular_posts, search_query)
    return regular_posts unless search_query.present?
    
    return regular_posts unless User.current

    # Check which platforms to include
    selected_platforms = []
    selected_platforms << 'mastodon' if include_mastodon
    selected_platforms << 'lemmy' if include_lemmy
    selected_platforms << 'reddit' if include_reddit
    selected_platforms << 'bluesky' if include_bluesky
    selected_platforms << 'peer' if include_peer
    
    # If none selected, return just regular posts
    return regular_posts if selected_platforms.empty?
    
    # Configure whether to use global search based on selection
    global_search = !selected_platforms.empty?
    
    # Get federated posts using the FederatedTimelineService
    service = ActivityPub::FederatedTimelineService.new(User.current)
    federated_posts = service.fetch_posts(
      page: 1,
      per_page: 20,
      search_query: search_query,
      global_search: global_search,
      platforms: selected_platforms
    )

    fedi_posts = federated_posts.map do |federated_post|
      FederatedPost.new(
        title: federated_post[:content].to_s.truncate(100),
        content: federated_post[:content],
        federated_author: federated_post[:federated_author],
        published_at: federated_post[:published],
        url: federated_post[:url],
        federated: true,
        platform: federated_post[:platform],
        created_at: Time.parse(federated_post[:published]),
        image_url: federated_post[:image_url]
      )
    end

    # Merge the two arrays and sort by created_at
    all_posts = (regular_posts.to_a + fedi_posts).sort_by(&:created_at).reverse
    
    # Return as a query-like object with pagination support
    Kaminari.paginate_array(all_posts)
  end
end

class FederatedPost
  attr_accessor :id, :title, :content, :federated_author, :published_at, :url, :federated, :created_at, :platform, :image_url
  
  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
    @id ||= SecureRandom.uuid
  end
  
  def federated?
    @federated || false
  end
end
