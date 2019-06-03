class RepoReport::Receivers

  def self.team_for(ua)
    ua.reporting_emps
  end

  def self.compute(item, date_range, selected_ua)
    team = selected_ua ? team_for(selected_ua) : nil
    raw = compute_data(item, date_range, team)
    raw.map do |r|
      p  = r["progress"].present? ? r["progress"].to_i : nil
      id = r["trackable_id"].to_i
      case r["trackable_type"]
        when "Person"
          ob = Person.find(id)
        when "Institution"
          ob = Institution.find(id)
        else
          ob = nil
      end

      { ob: ob,
        progress: p }
    end
  end

  private

  def self.compute_data(item, date_range, team)
    files_ids = item.tracker_files.pluck(:id)
    ua_q = team ? team.map(&:user_role_id).compact.join(",") : nil
    c = TrackerItem.connection
    s = date_range.start_on ? c.quoted_date(date_range.start_on.beginning_of_day) : nil
    e = date_range.end_on ? c.quoted_date(date_range.end_on.end_of_day) : nil

    TrackerItem.select_sql(<<-SQL, files_ids)
      select
        e.trackable_type  as trackable_type,
        e.trackable_id    as trackable_id,
        max(s.progress)   as progress

      from tracker_files f

      inner join tracker_file_events e on
        e.tracking_id = f.id
        #{ua_q ? "and e.user_role_id in (#{ua_q})" : "" }
        #{s ? "and e.created_at >= '#{s}'" : "" }
        #{e ? "and e.created_at <= '#{e}'" : "" }

      left join tracker_file_states s on
        s.tracking_id = f.id and
        s.trackable_type = e.trackable_type and
        s.trackable_id = e.trackable_id

      where
        f.id in (?)
      group by
        e.trackable_type, e.trackable_id
      order by
        progress desc nulls last
    SQL
  end

end