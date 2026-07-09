class AiPromptActivator
  def self.call(ai_prompt)
    new(ai_prompt).call
  end

  def initialize(ai_prompt)
    @ai_prompt = ai_prompt
  end

  def call
    ActiveRecord::Base.transaction do
      deactivate_previous_active
      @ai_prompt.update!(active: true)
    end
    @ai_prompt
  end

  private

  def deactivate_previous_active
    AiPrompt.where(ai_type: @ai_prompt.ai_type, active: true)
            .where.not(id: @ai_prompt.id)
            .update_all(active: false)
  end
end
