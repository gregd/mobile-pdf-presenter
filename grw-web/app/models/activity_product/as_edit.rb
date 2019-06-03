# == Schema Information
#
# Table name: activity_products
#
#  id                        :integer          not null, primary key
#  account_id                :integer
#  activity_product_group_id :integer
#  position                  :integer
#  name                      :string
#  abbr                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  deleted_at                :datetime
#  lock_version              :integer          default(0)
#

class ActivityProduct::AsEdit < ActivityProduct
  include ExtendedModel

  normalize_attributes :name, :abbr

  validates :position, presence: true
  validates :activity_product_group_id, presence: true
  validates :name, presence: true
  validates :abbr, presence: true

  before_validation :set_defaults

  def set_defaults
    self.position = (self.class.maximum(:position) || 0) + 1 if position.nil?
  end

end
