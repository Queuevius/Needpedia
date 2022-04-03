module Admin
  class UsersController < Admin::ApplicationController

    def update
      params[:user].delete(:password) if params[:user][:password].blank?
      super
    end

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
  end
end
