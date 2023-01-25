class DeletePostService
  def initialize(post_id, user_id)
    @post = Post.find(post_id)
    @user = User.find(user_id)
  end

  attr_accessor :post, :user

  def delete_post
    Post.unscoped do
      handle_subject_post_deletion if post.post_type == Post::POST_TYPE_SUBJECT
      handle_problem_post_deletion if post.post_type == Post::POST_TYPE_PROBLEM
      handle_idea_post_deletion if post.post_type == Post::POST_TYPE_IDEA
      handle_layer_post_deletion if post.post_type == Post::POST_TYPE_LAYER
    end
  end

  private

  def handle_subject_post_deletion
    posts = []
    posts << post
    posts << post.layers
    posts << post.child_posts.problem_posts
    posts << post.child_posts.idea_posts
    posts << post.child_posts.idea_posts.collect(&:layers)
    posts = posts.flatten
    posts.each do |p|
      p.update(deleted_at: Time.now)
      Deletion.create!(user_id: user.id, deletable_id: p.id, deletable_type: 'Post', reason: "Complete Post deletion including child posts and layers, post_id: #{post.id} by user: #{user.name}")
    end
  end

  def handle_problem_post_deletion
    posts = []
    posts << post
    posts << post.ideas
    posts << post.ideas.collect(&:layers)
    posts = posts.flatten
    posts.each do |p|
      p.update(deleted_at: Time.now)
      Deletion.create(user_id: user.id, deletable_id: p.id, deletable_type: 'Post', reason: "Problem Post deletion including idea posts and layers of idea posts, post_id: #{post.id} by user: #{user.name}")
    end
  end

  def handle_idea_post_deletion
    posts = []
    posts << post
    posts << post.layers
    posts = posts.flatten
    posts.each do |p|
      p.update(deleted_at: Time.now)
      Deletion.create(user_id: user.id, deletable_id: p.id, deletable_type: 'Post', reason: "Idea Post deletion including layers, post_id: #{post.id} by user: #{user.name}")
    end
  end

  def handle_layer_post_deletion
    posts = []
    posts << post
    posts = posts.flatten
    posts.each do |p|
      p.update(deleted_at: Time.now)
      Deletion.create(user_id: user.id, deletable_id: p.id, deletable_type: 'Post', reason: "layers deletion , post_id: #{post.id} by user: #{user.name}")
    end
  end
end
