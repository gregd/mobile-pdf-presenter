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

class OrgUnitAddress::AsEdit < OrgUnitAddress
  include ExtendedModel

  validates :org_unit_id, presence: true
  validates :address_id, presence: true
  validates :category, presence: true

  protect_account_forgery :address, :org_unit

end
