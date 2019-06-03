module Repo::Report::ItemsHelper

  def repo_pres_indicator(indicator, r, raw_value = false)
    case indicator
      when "time"
        repo_pres_duration(r[:duration], raw_value)
      when "avg_duration"
        repo_pres_duration(r[:avg_duration], raw_value)
      when "sessions"
        repo_pres_count(r[:sessions_count], raw_value)
      when "hits"
        repo_pres_count(r[:hits_count], raw_value)
    end
  end

  def repo_pres_count(d, raw_value)
    if raw_value
      d.nil? ? 0 : d
    else
      d
    end
  end

  def repo_pres_duration(d, raw_value)
    if raw_value
      d.nil? ? 0 : (d.to_f / 1000).round
    else
      d.nil? ? nil : seconds_to_h_m_s(d / 1000)
    end
  end

  def seconds_to_h_m_s(t)
    m, s = t.divmod(60)
    h, m = m.divmod(60)
    #d, h = h.divmod(24)

    if h > 0
      "#{h}h #{m}m"
    elsif m > 0
      "#{m}m #{s}s"
    else
      "#{s}s"
    end
  end

end