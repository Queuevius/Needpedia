class Users::OnboardingController < ApplicationController
  def update
    return head :unauthorized unless current_user
    return head :no_content if current_user.onboarding_completed?

    choice = params[:onboarding_choice]
    return head :unprocessable_entity unless %w[ai no_ai].include?(choice)

    # Atomic exactly-once: only the first writer (completed_at IS NULL) lands.
    rows = User.where(id: current_user.id, onboarding_completed_at: nil)
               .update_all(onboarding_choice: choice, onboarding_completed_at: Time.current, updated_at: Time.current)
    return head :no_content if rows == 1 || current_user.reload.onboarding_completed?

    head :internal_server_error
  end
end
