# Preview all emails at http://localhost:3000/rails/mailers/loc_daily_report_mailer
class LocDailyReportMailerPreview < ActionMailer::Preview

  def daily
    # TODO search by not id
    demo_account = Account.where(subdomain: "polskilek")
    report = LocReport::DailyEmail.compute(demo_account, Date.today).first
    raise "No any report for preview" unless report
    LocDailyReportMailer.daily(report)
  end

end
