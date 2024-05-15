module Admin
  class PostsController < Admin::ApplicationController
    include AdminActions
    require 'csv'
    def private_posts
      redirect_to admin_posts_path(private: true)
    end

    def deleted_posts
      redirect_to admin_posts_path(deleted_at: true)
    end

    def restore_deleted_posts
      Post.unscoped do
        post = Post.find(params[:id])
        case post.post_type
        when Post::POST_TYPE_SUBJECT
          handle_restore_subject_post
        when Post::POST_TYPE_PROBLEM
          handle_restore_problem_post
        when Post::POST_TYPE_IDEA
          handle_restore_idea_post
        else
          handle_restore_simple_post
        end
        create_activity(post, 'post.restore')
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

    def upload
      begin
        if params[:csv_file].present?
          csv_data = params[:csv_file].read
          CSV.parse(csv_data, headers: true) do |row|
            post = Post.new
            post.title = row['title']
            post.post_type = row['post_type']
            post.content = row['body']
            subject = Post.where(title: row['subject']).last if row['subject'].present?
            post.subject_id = subject.id if subject.present?
            problem = Post.where(title: row['problem']).last if row['problem'].present?
            post.problem_id = problem.id if problem.present?
            post.tag_list = row['tags']
            post.user = current_user
            post.save!
          end

          flash[:success] = "CSV file uploaded successfully"
          redirect_to admin_posts_path
        else
          flash[:error] = "Please select a file"
          redirect_to admin_posts_path
        end
      rescue StandardError => e
        flash[:error] = e.message
        redirect_to admin_posts_path
      end
    end

    private

    def handle_restore_subject_post
      post = Post.find(params[:id])
      posts = []
      posts << post
      posts << post.layers
      posts << post.child_posts.problem_posts
      posts << post.child_posts.idea_posts
      posts << post.child_posts.idea_posts.collect(&:layers)
      posts = posts.flatten
      posts.each do |p|
        p.update(deleted_at: nil, restore_at: Time.now)
      end
    end

    def handle_restore_problem_post
      post = Post.find(params[:id])
      posts = []
      posts << post
      posts << post.layers
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

    def handle_restore_simple_post
      post = Post.find(params[:id])
      posts = []
      posts << post
      posts = posts.flatten
      posts.each do |p|
        p.update(deleted_at: nil, restore_at: Time.now)
      end
    end

    def create_activity(post, event)
      ActivityService.new(object: post, event: event, owner: current_user, ip: request.remote_ip).call
    end
  end
end
