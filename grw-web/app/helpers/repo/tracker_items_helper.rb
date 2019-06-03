module Repo::TrackerItemsHelper

  def repo_file_rev_abbr(rev)
    return nil unless rev
    content_tag(:abbr, rev[0..7], title: rev)
  end

  def repo_file_mime_type(mt)
    case mt
      when "application/pdf"  then "PDF"
      when "video/mp4"        then "Video"
      else
        "Nieznana"
    end
  end

end
