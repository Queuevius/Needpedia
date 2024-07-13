module Admin
  class UsersController < Admin::ApplicationController
    include AdminActions

    def bulk_delete
      user_ids = params[:user_ids]
      return unless user_ids.present?

      users = User.where(id: user_ids)
      users.destroy_all
      redirect_to admin_users_path
    end

    def send_confirmation_link
      user = User.find(params[:id])
      if user.blank?
        flash[:alert] = 'Can not find this User'
      else
        user.send_confirmation_instructions.deliver
        flash[:notice] = 'Confirmation link has been sent on user email'
      end
      redirect_to admin_user_path(user)
    rescue StandardError => e
      flash[:alert] = e.message
      redirect_to admin_user_path(user)
    end

    def unconfirmed_users
      redirect_to admin_users_path(unconfirmed: true)
    end

    def scoped_resource
      if params[:unconfirmed] == 'true'
        resource_class.where(confirmed_at: nil, approved: false)
      else
        resource_class
      end
    end

    def user_history
      @user = User.find(params[:id])
      Post.unscoped do
        activities = PublicActivity::Activity.where(owner: @user).order(created_at: :desc)

        per_value = params[:per].present? ? params[:per].to_i : 10

        if params[:start_date].present? && params[:end_date].present?
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          @activities = activities.where(created_at: start_date.beginning_of_day..end_date.end_of_day).page(params[:page]).per(per_value)
        else
          @activities = activities.page(params[:page]).per(per_value)
        end
      end
    end

    def comment_user
      user = User.find(params[:id])
      if user.update(comment: params[:user][:comment])
        redirect_to admin_user_path(user), notice: "Comment was added successfully"
      else
        redirect_to admin_user_path(user), alert: "Comment was not added successfully"
      end
    end

    def update
      user = User.find(params[:id])

      if params[:features].present?
        features = params[:features]
        u_features = features.transform_values { |v| v == "1" }
        user.update(features: u_features)
      end
      super
    end
  end
end
