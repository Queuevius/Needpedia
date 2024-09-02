class AdminMailer < ApplicationMailer
  default from: 'support@needpedia.org'

  def ip_blacklisted(ip)
    @ip = ip
    mail(to: 'anthonydunn97202@gmail.com', subject: 'IP Address Blacklisted')
  end
end
