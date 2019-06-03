class LocDailyReportMailer < ApplicationMailer
  helper 'loc/location_summaries'

  def daily(report)
    @account  = report[:account]
    @data     = report[:data]
    @day      = report[:day]
    @host     = host_for(report[:account])

    mail(to:      report[:emails],
         subject: "Raport lokalizacji #{@day}")
  end

end
