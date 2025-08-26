module MasterAdmin
  class WebhooksController < MasterAdmin::ApplicationController
    def index
      @receiving_enabled = WebhookSetting.webhook_receiving_enabled?
      @logging_enabled = false
    end

    def update_settings
      WebhookSetting.set('webhook_receiving_enabled', params[:receiving_enabled] == '1' ? 'true' : 'false')
      redirect_to master_admin_webhooks_path, notice: 'Webhook settings updated.'
    end

    # no log actions
  end
end


