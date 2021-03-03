module Admin
  class UsersController < Admin::ApplicationController
    def bulk_delete
      user_ids = params[:user_ids]
      return unless user_ids.present?

      users = User.where(id: user_ids)
      users.destroy_all
      redirect_to admin_users_path
    end
  end
end
