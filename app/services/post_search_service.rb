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
  end

  attr_accessor :ransack_fields, :access_type, :sorted_by, :post_type, :subject, :problem, :idea, :resource_tags, :location_tags

  def filter
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
    else
      posts = posts.where(post_type: post_type)
    end

    posts
  end

  private

  def posts_with_access(access_type, posts)
    if access_type == 'Public'
      posts = posts.where(private: false)
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
end