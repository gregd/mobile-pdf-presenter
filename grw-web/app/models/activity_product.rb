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

class ActivityProduct < ApplicationRecord
  include AccountScoped
  include WithPresenter

  belongs_to :activity_product_group

  scope :active, -> { where("activity_products.deleted_at IS NULL") }

end
