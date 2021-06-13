class PostSearchService
  def initialize(params)
    @ransack_fields = params[:q]
    @access_type = params[:access_type]
    @sorted_by = params[:sorted_by]
  end

  attr_accessor :ransack_fields, :access_type, :sorted_by

  def filter
    q = Post.ransack(ransack_fields)

    posts = q.result(distinct: true)

    if access_type.present?
      posts = posts_with_access(access_type, posts)
    end

    if sorted_by.present?
      sort_posts(sorted_by, posts)
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