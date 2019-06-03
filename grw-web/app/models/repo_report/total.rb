class RepoReport::Total

  def self.compute(items, date_range, selected_ua)
    raw = compute_data(items, date_range, selected_ua)

    current_item_id = nil
    result = []
    days = nil

    raw.each do |r|
      item_id = r["item_id"].to_i
      if item_id != current_item_id
        current_item_id = item_id
        days = []
        result << {
          item: TrackerItem.find(current_item_id),
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

    result
  end

  private

  def self.compute_data(items, date_range, selected_ua)
    session_break = RepoReport::Items::SESSION_BREAK

    items_ids = items.map {|i| i.id }
    items_q = items.sort_by {|i| i.base_name }.map.with_index {|i, index| "(#{i.id},#{index})" }.join(",")

    ur_ids = selected_ua.reporting_emps.map(&:user_role_id).compact

    raw = TrackerItem.select_sql(<<-SQL, date_range.start_on, date_range.end_on, items_ids, ur_ids, date_range.start_on.beginning_of_day, date_range.end_on.end_of_day)
      select
        d.day             as day,
        items.id          as item_id,
        r.sessions_count  as sessions_count,
        r.duration        as duration,
        r.duration / r.sessions_count as avg_duration
      from
        (select dd::date as day
         from generate_series(?, ?, '1 day'::interval) as dd) d
      cross join
        (values #{items_q}) items(id, pos)
      left join (
        select
          q3.item_id        as item_id,
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
              lag(created_at) over (partition by day, ua_id, item_id order by created_at) as prev_ts
            from (
              select
                cast(e.created_at as date)  as day,
                f.tracker_item_id           as item_id,
                e.user_role_id              as ua_id,
                e.created_at                as created_at,
                e.duration                  as duration
              from
                tracker_file_events e
              inner join
                tracker_files f
              on
                f.id = e.tracking_id
              where
                f.tracker_item_id in (?) and
                e.user_role_id in (?) and
                e.created_at between ? and ?) q1) q2) q3
        group by
          item_id, day) r
      on
        r.day = d.day and
        r.item_id = items.id
      order by
        items.pos, d.day
    SQL

    raw
  end

end