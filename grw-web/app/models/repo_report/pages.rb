class RepoReport::Pages
  INDICATOR_OPTIONS = [["Wyświetleń", "hits"], ["Czas na stronie", "time"], ["Śr. czas na stronie", "avg_duration"]].freeze
  INDICATOR_VALUES = INDICATOR_OPTIONS.map {|i| i[1] }.freeze
  INDICATOR_MAP = INDICATOR_OPTIONS.to_h.invert.freeze

  def self.team_for(ua)
    ua.reporting_emps
  end

  def self.compute(item, date_range, selected_ua)
    team = team_for(selected_ua)
    raw = compute_data(item, date_range, team)

    current_emp_id = nil
    result = []
    pages = nil

    raw.each do |r|
      emp_id = r["emp_id"].to_i
      if emp_id != current_emp_id
        current_emp_id = emp_id
        pages = []
        result << {
          emp: team.find {|ua| ua.id == current_emp_id },
          pages: pages }
      end

      page          = r["page"].to_i
      hits_count    = r["hits_count"].try(:to_i)
      duration      = r["duration"].try(:to_i)
      avg_duration  = r["avg_duration"].try(:to_i)

      pages << {
        page: page,
        duration: duration,
        avg_duration: avg_duration,
        hits_count: hits_count }
    end

    aggregate_up(result)

    result
  end

  private

  def self.aggregate_up(result)

    id_2_pages = {}
    result.each do |r|
      id_2_pages[r[:emp].id] = r[:pages]
    end

    # reverse because we have to aggregate regions before aggregating whole team
    result.reverse.each do |r|
      emp = r[:emp]
      next if emp.leaf?

      children = emp.children.pluck(:id).map {|i| id_2_pages[i] }.compact
      next if children.size == 0

      days = r[:pages]
      (0 .. (days.size - 1)).each do |i|
        child_arr   = children.map {|a| a[i] }
        duration    = child_arr.map {|d| d[:duration] }.compact.sum
        hits_count  = child_arr.map {|d| d[:hits_count] }.compact.sum
        if duration && duration > 0
          days[i][:duration] = duration
        end
        if hits_count && hits_count > 0
          days[i][:hits_count] = hits_count
          days[i][:avg_duration] = (duration / hits_count).try(:to_i)
        end
      end
    end
  end

  def self.compute_data(item, date_range, team)
    files_ids = item.tracker_files.pluck(:id)
    ua_q = team.map {|ua| "(#{ua.id},#{ua.user_role_id ? ua.user_role_id : 'null::integer'},#{ua.node_order})" }.join(",")
    ua_ids = team.map(&:user_role_id)

    raw = TrackerItem.select_sql(<<-SQL, item.pages - 1, files_ids, ua_ids, date_range.start_on.beginning_of_day, date_range.end_on.end_of_day)
      select
        ua.emp_id         as emp_id,
        pages.page        as page,
        r.hits_count      as hits_count,
        r.duration        as duration,
        r.duration / r.hits_count as avg_duration
      from
        (select generate_series(0, ?, 1) as page) pages
      cross join
        (values #{ua_q}) ua(emp_id, ur_id, pos)
      left join (
        select
          e.user_role_id        as emp_id,
          e.page                as page,
          count(*)              as hits_count,
          sum(duration)         as duration
        from
          tracker_file_events e
        where
          e.tracking_id in (?) and
          e.user_role_id in (?) and
          e.created_at between ? and ?
        group by
          e.user_role_id, e.page) r
      on
        r.emp_id = ua.ur_id and
        r.page = pages.page
      order by
        ua.pos, pages.page
    SQL

    raw
  end

end