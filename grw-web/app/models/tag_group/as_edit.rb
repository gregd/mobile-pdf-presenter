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

class TagGroup::AsEdit < TagGroup
  include ExtendedModel

  normalize_attributes :name, :abbr, :color
  normalize_attributes :klasses, with: :pg_array

  validates :position, presence: true
  validates :name, presence: true
  validates :abbr, presence: true

  before_validation :set_defaults

  def set_defaults
    self.position = (self.class.maximum(:position) || 0) + 1 if position.nil?
    self.has_hierarchy = false    if has_hierarchy.nil?
    self.has_uniqueness = false   if has_uniqueness.nil?
    self.has_main_tagging = false if has_main_tagging.nil?
    self.is_eco_sector = false    if is_eco_sector.nil?
    self.is_target = false        if is_target.nil?
  end

  def self.klasses_opt
    KLASSES_OPT
  end

end
