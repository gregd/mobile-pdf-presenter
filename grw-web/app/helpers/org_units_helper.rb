module OrgUnitsHelper

  def rw_collab_icon(collab)
    icon = case collab
             when "lead"    then "icon-question7"
             when "lost"    then "icon-alert"
             when "client"  then "icon-coin-euro"
             when "paused"  then "icon-heart-broken2"
             else raise "unknown collab '#{collab}'"
           end
    content_tag :i, "", class: icon
  end

end
