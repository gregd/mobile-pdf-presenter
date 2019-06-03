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

class TagGroup::AsPresenter < TagGroup
  include ExtendedModel

  def view_klasses
    klasses.map {|k| KLASSES_MAP[k] }
  end

end
