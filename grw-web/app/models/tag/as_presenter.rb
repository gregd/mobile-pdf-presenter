# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  tag_group_id   :integer
#  parent_id      :integer
#  path           :ltree
#  children_count :integer
#  position       :integer
#  name           :string
#  abbr           :string
#  description    :string
#  color          :string
#  default_tag    :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#

class Tag::AsPresenter < Tag
  include ExtendedModel

  def view_as_label(klass: "", style: "")
    klass, style = klass_style(klass, style)
    "<span class='#{klass}' style='#{style}'>#{name}</span>".html_safe
  end

  def view_as_label_abbr(klass: "", style: "")
    klass, style = klass_style(klass, style)
    "<span class='#{klass}' style='#{style}' title='#{name}'>#{abbr}</span>".html_safe
  end

  private

  def klass_style(klass, style)
    if color
      klass = "label #{klass}"
      style = "background-color: #{color}; #{style}"
    else
      klass = "label label-default #{klass}"
      style = "#{style}"
    end

    [klass, style]
  end

end
