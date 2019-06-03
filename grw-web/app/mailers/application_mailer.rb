class ApplicationMailer < ActionMailer::Base
  default from: 'support@example.com'
  layout 'mailer'

  protected

  def host_for(account)
    if Rails.env.production?
      "https://#{account.subdomain}.example.com"
    else
      "http://#{account.subdomain}.gd.pl:3000"
    end
  end

end
