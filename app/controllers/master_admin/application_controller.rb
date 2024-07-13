# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module MasterAdmin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_master_admin

    def authenticate_master_admin
      redirect_to '/', alert: 'Not authorized.' unless user_signed_in? && current_user.master_admin?
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
