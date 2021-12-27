class FeedbacksController < ApplicationController
  def new
    @feedback = @current_user.feedbacks.new
    FeedbackQuestion.find_each do |question|
      @feedback.feedback_responses.build(feedback_question: question)
    end
  end

  def create
    @feedback = @current_user.feedbacks.new(response_params)
    if @feedback.save
      redirect_to edit_user_registration_path, notice: 'Thanks for your feedback.'
    else
      flash[:alert] = @feedback.errors.full_messages.join(',')
      redirect_to new_feedback_path
    end
  end

  private

  def response_params
    params.require(:feedback).permit(feedback_responses_attributes: [:id, :feedback_question_id, :feedback_question_option_id, :comment, :_destroy])
  end
end
