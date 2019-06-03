class RepoReport::Items
  SESSION_BREAK = 5.freeze    # minutes
  INDICATOR_OPTIONS = [["Liczba sesji", "sessions"], ["Śr. czas sesji", "avg_duration"], ["Czas", "time"]].freeze
  INDICATOR_VALUES = INDICATOR_OPTIONS.map {|i| i[1] }.freeze

  def self.team_for(ua)
    ua.reporting_emps
  end

  def self.compute(item, date_range, selected_ua)
    team = team_for(selected_ua)
    raw = compute_data(item, date_range, team)

    current_emp_id = nil
    result = []
    days = nil

    raw.each do |r|
      emp_id = r["emp_id"].to_i
      if emp_id != current_emp_id
        current_emp_id = emp_id
        days = []
        result << {
          emp: team.find {|e| e.id == current_emp_id },
          days: days }
      end

      day = Date.parse(r["day"])
      sessions_count  = r["sessions_count"].try(:to_i)
      duration        = r["duration"].try(:to_i)
      avg_duration    = r["avg_duration"].try(:to_i)

      days << {
        day: day,
        duration: duration,
        avg_duration: avg_duration,
        sessions_count: sessions_count }
    end

    aggregate_up(result)

    result
  end

  private

  def self.aggregate_up(result)

    id_2_days = {}
    result.each do |r|
      id_2_days[r[:emp].id] = r[:days]
    end

    # reverse because we have to aggregate regions before aggregating whole team
    result.reverse.each do |r|
      emp = r[:emp]
      next if emp.leaf?

      children = emp.children.pluck(:id).map {|i| id_2_days[i] }.compact
      next if children.size == 0

      days = r[:days]
      (0 .. (days.size - 1)).each do |i|
        child_days      = children.map {|a| a[i] }
        duration        = child_days.map {|d| d[:duration] }.compact.sum
        sessions_count  = child_days.map {|d| d[:sessions_count] }.compact.sum
        if duration && duration > 0
          days[i][:duration] = duration
        end
        if sessions_count && sessions_count > 0
          days[i][:sessions_count] = sessions_count
          days[i][:avg_duration] = (duration / sessions_count).try(:to_i)
        end
      end
    end
  end

  def self.compute_data(item, date_range, team)
    session_break = SESSION_BREAK
    files_ids = item.tracker_files.pluck(:id)
    ua_q = team.map {|ua| "(#{ua.id},#{ua.user_role_id ? ua.user_role_id : 'null::integer'},#{ua.node_order})" }.join(",")
    ua_ids = team.map(&:user_role_id).compact

    raw = TrackerItem.select_sql(<<-SQL, date_range.start_on, date_range.end_on, files_ids, ua_ids, date_range.start_on.beginning_of_day, date_range.end_on.end_of_day)
      select
        d.day             as day,
        ua.emp_id         as emp_id,
        ua.ur_id          as ur_id,
        r.sessions_count  as sessions_count,
        r.duration        as duration,
        r.duration / r.sessions_count as avg_duration
      from
        (select dd::date as day
         from generate_series(?, ?, '1 day'::interval) as dd) d
      cross join
        (values #{ua_q}) ua(emp_id, ur_id, pos)
      left join (
        select
          q3.ua_id          as ua_id,
          q3.day            as day,
          sum(q3.is_start)  as sessions_count,
          sum(q3.duration)  as duration
        from (
          select
            q2.*,
            (case when prev_ts is null or prev_ts < created_at - interval '#{session_break} minutes' then 1 else 0 end) as is_start
          from (
            select
              q1.*,
              lag(created_at) over (partition by day, ua_id order by created_at) as prev_ts
            from (
              select
                cast(created_at as date)  as day,
                user_role_id              as ua_id,
                created_at                as created_at,
                duration                  as duration
              from
                tracker_file_events
              where
                tracking_id in (?) and
                user_role_id in (?) and
                created_at between ? and ?) q1) q2) q3
        group by
          ua_id, day) r
      on
        r.day = d.day and
        r.ua_id = ua.ur_id
      order by
        ua.pos, d.day
    SQL

    raw
  end

end