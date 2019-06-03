namespace :rw do
  namespace :notifications do

    desc "Send daily email reports summarizing for previous day."
    task :send_daily_emails => :environment do
      LocReport::DailyEmail.compute.each do |report|
        LocDailyReportMailer.daily(report).deliver_now
      end
    end

  end
end
