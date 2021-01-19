module Admin
  class PostsController < Admin::ApplicationController
    def private_posts
      redirect_to admin_posts_path(private: true)
    end

    def scoped_resource
      if params[:private] == 'true'
        resource_class.where(private: true)
      else
        resource_class
      end
    end
  end
end
