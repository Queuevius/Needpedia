module Admin
  class BlockedIpsController < Admin::ApplicationController
    def unblock
      blocked_ip = BlockedIp.find(params[:id])
      blocked_ip.destroy
      redirect_to admin_blocked_ips_path, notice: "IP #{blocked_ip.ip} has been unblocked."
    end
  end
end
