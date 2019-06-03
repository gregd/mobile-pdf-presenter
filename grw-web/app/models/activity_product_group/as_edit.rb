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

class ActivityProductGroup::AsEdit < ActivityProductGroup
  include ExtendedModel

  normalize_attributes :name, :abbr
  normalize_attributes :klasses, with: :pg_array

  validates :position, presence: true
  validates :name, presence: true
  validates :abbr, presence: true

  before_validation :set_defaults

  def set_defaults
    self.position = (self.class.maximum(:position) || 0) + 1 if position.nil?
  end

  def self.klasses_opt
    KLASSES_OPT
  end

end
