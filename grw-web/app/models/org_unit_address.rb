# == Schema Information
#
# Table name: org_unit_addresses
#
#  id           :integer          not null, primary key
#  account_id   :integer
#  org_unit_id  :integer
#  address_id   :integer
#  address_uuid :uuid
#  category     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#  lock_version :integer          default(0)
#

class OrgUnitAddress < ApplicationRecord
  include AccountScoped
  belongs_to :org_unit
  belongs_to :address

  ADDR_MAIN = "main"

  scope :active, -> { where("org_unit_addresses.deleted_at IS NULL") }
  scope :addr_main, -> { where("org_unit_addresses.category = ?", ADDR_MAIN) }

end
