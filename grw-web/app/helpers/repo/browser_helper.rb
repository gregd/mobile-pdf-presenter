module Repo::BrowserHelper

  def repo_path_links(path)
    parts = []
    if path.present?
      path.split("/").inject(nil) {|sum, d| res = sum.nil? ? d : File.join(sum, d); parts << res; res }
    end

    content_tag(:ul, class: "breadcrumb breadcrumb-caret rwc-RepoBrowserLocation") do
      content_tag(:li) do
        content_tag(:i, "", class: "icon-folder4 position-left rwc-RepoBrowserLocation-icon") +
          link_to("Start", repo_browser_index_path)
      end +
        parts.map.with_index do |p, index|
          if index == parts.size - 1
            content_tag(:li, class: "active") do
              File.basename(p)
            end
          else
            content_tag(:li, {}) do
              link_to File.basename(p), repo_browser_index_path(path: p)
            end
          end
        end.join.html_safe
    end
  end

end
