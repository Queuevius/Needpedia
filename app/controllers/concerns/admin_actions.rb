module AdminActions
  extend ActiveSupport::Concern

  def create
    if resource_class.model_name.singular == "user"
      email = params[:user][:email]
      user = User.find_by(email: email)
      if user && user.confirmed_at.nil?
        user.destroy
      end
    end

    resource = resource_class.new(resource_params)

    if resource.save
      redirect_to [namespace, resource], notice: "#{resource.class.model_name.singular}  was successfully created."

      create_admin_history_log(resource.id)
    else
      render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
      }
    end
  end

  def update
    if resource_class.model_name.singular == "user"
      params[:user].delete(:password) if params[:user][:password].blank?
    end
    super
    create_admin_history_log(params[:id])
  end

  def show
    super
    if resource_class.model_name.singular == "user"
      create_admin_history_log(params[:id])
    end
  end

  def destroy
    if resource_class.model_name.singular == "post"
      Post.unscoped do
        post = Post.find(params[:id])
        create_admin_history_log(post.id)
        create_activity(post, 'post.destroy')
        post.destroy
        redirect_to admin_posts_path, notice: 'Post was successfully destroyed.'
      end
    else
      create_admin_history_log(params[:id])
      super
    end
  end

  def create_admin_history_log(id = nil)
    action = action_name.capitalize
    target_type = controller_name.singularize.capitalize

    message = if id.nil? || target_type == "User"
                id ||= params[:id]
                "Admin looked at a user profile"
              else
                "Admin #{action}d #{target_type}"
              end

    AdminHistory.create(
        user: current_user,
        action: action,
        target_type: target_type,
        target_id: id,
        message: message,
        ip_address: request.remote_ip
    )
  end
end
