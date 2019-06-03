# == Schema Information
#
# Table name: activity_product_groups
#
#  id         :integer          not null, primary key
#  account_id :integer
#  klasses    :string           default([]), not null, is an Array
#  position   :integer
#  name       :string
#  abbr       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class ActivityProductGroup < ApplicationRecord
  include AccountScoped
  include WithPresenter

  has_many :activity_products, -> { active }

  scope :active, -> { where("activity_product_groups.deleted_at IS NULL") }

  KLASSES_MAP = { "ActivityVisit" => "Wizyty", "ActivityCall"  => "Telefony", "ActivitySnailMail" => "Mailingi" }.freeze
  KLASSES_OPT = KLASSES_MAP.invert.to_a.freeze
  KLASSES_VALUES = KLASSES_MAP.keys.freeze

end
