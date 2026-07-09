module MasterAdmin
  class AiPromptsController < MasterAdmin::ApplicationController
    helper AiPromptDiffHelper
    def scoped_resource
      resource_class.order(ai_type: :asc, version: :desc)
    end

    def activate
      prompt = AiPrompt.find(params[:id])
      prompt.activate
      redirect_to master_admin_ai_prompts_path, notice: "Activated #{prompt.ai_type} v#{prompt.version}"
    end

    def update
      new_record = AiPrompt.new(resource_params)

      if new_record.save
        redirect_to master_admin_ai_prompts_path,
                    notice: "Created #{new_record.ai_type} v#{new_record.version}"
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, new_record)
        }
      end
    end
  end
end
