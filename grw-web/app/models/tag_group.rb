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

class TagGroup < ApplicationRecord
  include AccountScoped
  include WithPresenter

  has_many :all_tags, class_name: "Tag", dependent: :destroy
  has_many :tags, -> { active }

  scope :active, -> { where("tag_groups.deleted_at IS NULL") }

  KLASSES_MAP = { "OrgUnit" => "Firmy", "Person"  => "Osoby" }.freeze
  KLASSES_OPT = KLASSES_MAP.invert.to_a.freeze
  KLASSES_VALUES = KLASSES_MAP.keys.freeze

end
