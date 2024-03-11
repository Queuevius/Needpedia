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

    def bulk_delete
      answers_ids = params[:answers_ids]
      return unless answers_ids.present?

      begin
        Answer.where(id: answers_ids).destroy_all
        flash[:notice] = "Selected answers have been deleted successfully."
      rescue => e
        flash[:alert] = "An error occurred while deleting selected answers: #{e.message}"
      end
      redirect_to master_admin_answers_path
    end

    def destroy_all
      begin
        Answer.destroy_all
        flash[:notice] = "All answers have been deleted successfully."
      rescue => e
        flash[:alert] = "An error occurred while deleting all answers: #{e.message}"
      end
      redirect_to master_admin_answers_path
    end
  end
end
