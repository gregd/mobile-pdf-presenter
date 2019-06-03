class TrackerFileState::Service

  def initialize(events_from = nil)
    # recompute last 7 days because tablet sync might be delayed (e.g. off for the weekend)
    @events_from = events_from || 7.days.ago.beginning_of_day
  end

  def execute
    modified_items.each_pair do |item_id, arr|
      item = TrackerItem.find(item_id)
      arr.each do |h|
        TrackerFileState.transaction do
          if item.pdf?
            pages = viewed_pages(item, h[:trackable_type], h[:trackable_id])
            update_page_progress(item, h[:trackable_type], h[:trackable_id], pages)

          elsif item.video?
            ranges = viewed_ranges(item, h[:trackable_type], h[:trackable_id])
            update_video_progress(item, h[:trackable_type], h[:trackable_id], ranges)
          end
        end
      end
    end
  end

  private

  def modified_items
    res = TrackerFile.select_sql(<<-SQL, @events_from)
      select
        f.tracker_item_id as iid,
        e.trackable_type as ttype,
        e.trackable_id as tid
      from
        tracker_file_events e
      inner join tracker_files f on
        f.id = e.tracking_id
      where
        e.trackable_id is not null and
        e.created_at >= ?
      group by
        f.tracker_item_id, e.trackable_type, e.trackable_id
      order by
        f.tracker_item_id, e.trackable_type, e.trackable_id
    SQL
    res = res.map {|r| { item_id: r["iid"].to_i, trackable_type: r["ttype"], trackable_id: r["tid"].to_i } }
    res.group_by {|r| r[:item_id] }
  end

  def viewed_pages(item, trackable_type, trackable_id)
    res = TrackerFile.select_sql(<<-SQL, trackable_type, trackable_id, item.id)
      select
        e.page as page
      from
        tracker_files f
      inner join tracker_file_events e on
        e.tracking_id = f.id and
        e.trackable_type = ? and
        e.trackable_id = ?
      where
        f.tracker_item_id = ?
      group by
        e.page
      order by
        e.page
    SQL
    res.map {|r| r["page"].to_i }.reject {|i| i > item.pages }.sort
  end

  def update_page_progress(item, trackable_type, trackable_id, viewed)
    if item.pages.nil? || viewed.size == 0
      progress = 0
      extras = nil
    else
      progress = ((viewed.size * 100.0) / item.pages).round
      extras = pack_pages(viewed)
    end

    files_ids = item.tracker_files.pluck(:id)
    TrackerFileState.where(tracking_id: files_ids, trackable_type: trackable_type, trackable_id: trackable_id).each do |s|
      s.progress = progress
      s.extras = extras
      s.save!
    end
  end

  def pack_pages(arr)
    return nil if arr.empty?

    cur = nil
    count = nil
    res = []

    (arr.first .. arr.last).each do |i|
      next unless arr.include?(i)
      if cur.nil?
        cur = i
        count = 1
      else
        if cur + count == i
          count += 1
        else
          res << [cur, count]
          cur = i
          count = 1
        end
      end
    end

    if cur
      res << [cur, count]
    end

    res.map {|a| a[1] > 1 ? "#{a[0]},#{a[1] - 1}" : a[0].to_s  }.join("|")
  end

  def viewed_ranges(item, trackable_type, trackable_id)
    files_ids = item.tracker_files.pluck(:id)
    res = TrackerFile.select_sql(<<-SQL, files_ids, trackable_type, trackable_id)
      select
        t.time_point
      from (
        select unnest(array[case when r.range_begin then cur_begin else null end,
                            case when r.range_end then cur_end else null end]) as time_point
        from (
          select
            q.cur_begin,
            q.cur_end,
            max_before is null or max_before < cur_begin as range_begin,
            min_after is null or cur_end < min_after     as range_end
          from (
            select
              beginning            as cur_begin,
              beginning + duration as cur_end,
              max(beginning + duration) over (order by beginning rows between unbounded preceding and 1 preceding) as max_before,
              min(beginning) over (order by beginning + duration rows between 1 following and unbounded following) as min_after
            from
              tracker_file_events
            where
              tracking_id in (?) and
              trackable_type = ? and
              trackable_id = ?
          ) q
        ) r
      ) t
      where
        t.time_point is not null
      order by
        t.time_point
    SQL
    res.map {|r| r["time_point"].to_i }.each_slice(2).to_a
  end

  def update_video_progress(item, trackable_type, trackable_id, ranges)
    if item.seconds.nil? || ranges.empty?
      progress = 0

    else
      seconds = (ranges.map {|p| p[1] - p[0] }.sum / 1000.0).round
      progress = ((seconds * 100.0) / item.seconds).round
      progress = 100 if progress > 100 # just in case of rounding errors
    end

    files_ids = item.tracker_files.pluck(:id)
    TrackerFileState.where(tracking_id: files_ids, trackable_type: trackable_type, trackable_id: trackable_id).each do |s|
      s.progress = progress
      s.save!
    end
  end

end