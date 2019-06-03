module Admin::MobileDevicesHelper

  def admin_mobile_repo_rev_abbr(rev)
    return nil unless rev
    content_tag(:abbr, rev[0..7], title: rev)
  end

  def admin_mobile_gms_abbr(ver)
    return nil unless ver
    content_tag(:abbr, ver[0..5], title: ver)
  end

end
