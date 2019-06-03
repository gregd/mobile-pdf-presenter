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

class Tag::AsDict < Tag
  include ExtendedModel

  def self.for_klass(klass)
    result = []
    TagGroup::AsDict.for_klass(klass).map do |group|
      result.concat group.tags.order("position").pluck(:name, :id)
    end
    result
  end

end
