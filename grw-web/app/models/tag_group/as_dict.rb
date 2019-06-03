# == Schema Information
#
# Table name: tag_groups
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  position         :integer
#  klasses          :string           default([]), not null, is an Array
#  name             :string
#  abbr             :string
#  color            :string
#  has_hierarchy    :boolean          default(FALSE), not null
#  has_uniqueness   :boolean          default(FALSE), not null
#  has_main_tagging :boolean          default(FALSE), not null
#  is_eco_sector    :boolean          default(FALSE), not null
#  is_target        :boolean          default(FALSE), not null
#  is_important     :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

class TagGroup::AsDict < TagGroup
  include ExtendedModel

  def self.all_groups
    active.order("position").map {|g| [g.name, g.id] }
  end

  def self.groups_with_tags(klass, only_important = true)
    q = for_klass(klass)
    q = q.where("is_important IS TRUE") if only_important
    q.to_a.map {|g| [g, g.tags.order("tags.position").to_a] }
  end

  def self.for_klass(klass)
    active.where("? = ANY(klasses)", klass).order("position")
  end

end
