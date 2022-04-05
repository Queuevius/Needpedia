module MasterAdmin
  class AnswersController < MasterAdmin::ApplicationController
    def approve_user
      answer = Answer.find(params[:answer_id])
      user = answer.user
      if answer.blank? || user.blank?
        flash[:alert] = 'Can not find this User'
      else
        user.update!(approved: true)
        user.send_confirmation_instructions.deliver
        flash[:notice] = 'Confirmation link has been sent on user email'
      end
      redirect_to master_admin_answer_path(answer)
    rescue StandardError => e
      flash[:alert] = e.message
      redirect_to master_admin_answer_path(answer)
    end
  end
end
