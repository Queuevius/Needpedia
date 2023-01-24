module Admin
  class PostsController < Admin::ApplicationController
    def private_posts
      redirect_to admin_posts_path(private: true)
    end

    def deleted_posts
      redirect_to admin_posts_path(deleted_at: true)
    end

    def restore_deleted_posts
      Post.unscoped do
        post = Post.find(params[:id])
        handle_restore_subject_post if post.post_type == Post::POST_TYPE_SUBJECT
        handle_restore_problem_post if post.post_type == Post::POST_TYPE_PROBLEM
        handle_restore_idea_post if post.post_type == Post::POST_TYPE_IDEA
        handle_restore_layer_post if post.post_type == Post::POST_TYPE_LAYER
      end
      redirect_to admin_posts_path
    end

    def scoped_resource
      if params[:private] == 'true'
        resource_class.where(private: true)
      elsif params[:deleted_at] == 'true'
        resource_class.unscoped.where.not(deleted_at: nil)
      else
        resource_class.where(deleted_at: nil)
      end
    end


    private

    def handle_restore_subject_post
      post = Post.find(params[:id])
      posts_arr = []
      posts_arr << post
      posts_arr << post.layers
      posts_arr << post.child_posts.problem_posts
      posts_arr << post.child_posts.idea_posts
      posts_arr << post.child_posts.idea_posts.collect(&:layers)
      posts_arr = posts_arr.flatten
      posts_arr.each do |p|
        p.update(deleted_at: nil, restore_at: Time.now)
      end
    end

    def handle_restore_problem_post
      post = Post.find(params[:id])
      posts = []
      posts << post
      posts << post.ideas
      posts << post.ideas.collect(&:layers)
      posts = posts.flatten
      posts.each do |p|
        p.update(deleted_at: nil, restore_at: Time.now)
      end
    end

    def handle_restore_idea_post
      post = Post.find(params[:id])
      posts = []
      posts << post
      posts << post.layers
      posts = posts.flatten
      posts.each do |p|
        p.update(deleted_at: nil, restore_at: Time.now)
      end
    end

    def handle_restore_layer_post
      post = Post.find(params[:id])
      posts = []
      posts << post
      posts = posts.flatten
      posts.each do |p|
        p.update(deleted_at: nil, restore_at: Time.now)
      end
    end
  end
end
