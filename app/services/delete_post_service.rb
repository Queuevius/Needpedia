class DeletePostService
  def initialize(post_id, user_id)
    @post = Post.find(post_id)
    @user = User.find(user_id)
  end

  attr_accessor :post, :user

  def delete_post
    Post.unscoped do
      case post.post_type
      when Post::POST_TYPE_SUBJECT
        handle_subject_post_deletion
      when Post::POST_TYPE_PROBLEM
        handle_problem_post_deletion
      when Post::POST_TYPE_IDEA
        handle_idea_post_deletion
      else
        handle_simple_post_deletion
      end
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
    posts << post.layers
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

  def handle_simple_post_deletion
    posts = []
    posts << post
    posts = posts.flatten
    posts.each do |p|
      p.update(deleted_at: Time.now)
      Deletion.create(user_id: user.id, deletable_id: p.id, deletable_type: 'Post', reason: "Post deletion , post_id: #{post.id} by user: #{user.name}")
    end
  end
end
