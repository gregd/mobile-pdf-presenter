class LocReport::DailyEmail

  def self.compute(accounts = nil, day = nil)
    accounts = Account.active unless accounts
    day = Date.today - 1 unless day

    result = []
    accounts.each do |account|
      next if account.config.daily_report_emails.empty?
      Account.set_current(account)

      EmpPosition.active.roots.where("account_id = ?", account.id).each do |emp|
        team = emp.reporting_emps(filter: :all)
        data = LocReport::WorkTime.compute(team, day)
        result << {
          account: account,
          emails: account.config.daily_report_emails.join(","),
          data: data,
          day: day }
      end
    end

    result
  end

end