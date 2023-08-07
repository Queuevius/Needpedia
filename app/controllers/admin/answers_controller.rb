module Admin
  class AnswersController < Admin::ApplicationController
    include AdminActions
    def approve_user
      answer = Answer.find(params[:answer_id])
      user = answer.user
      redirect_to_page = params[:redirect_to]
      if answer.blank? || user.blank?
        flash[:alert] = 'Can not find this User'
      else
        user.update!(approved: true)
        user.send_confirmation_instructions.deliver
        flash[:notice] = 'Confirmation link has been sent on user email'
      end
      redirect_to redirect_to_page == "answer_page" ? admin_answer_path(answer) : unconfirmed_users_admin_users_path
    rescue StandardError => e
      flash[:alert] = e.message
      redirect_to admin_users_path
    end
  end
end
