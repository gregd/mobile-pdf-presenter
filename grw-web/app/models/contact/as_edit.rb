# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  uuid             :uuid
#  contactable_uuid :uuid
#  contactable_id   :integer
#  contactable_type :string
#  category         :string
#  address          :string
#  comments         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  lock_version     :integer          default(0)
#

class Contact::AsEdit < Contact
  include ExtendedModel

  normalize_attributes :address, :comments

  validates :uuid, presence: true
  validates :contactable_uuid, presence: true
  validates :contactable_id, presence: true
  validates :contactable_type, presence: true, inclusion: %w(Person OrgUnit)
  validates :address, presence: true
  validates :category, presence: true, inclusion: CATEGORIES_VALUES

  protect_account_forgery :contactable

  before_validation :set_defaults

  def set_defaults
    self.uuid = SecureRandom.uuid unless uuid
    self.contactable_uuid = contactable.uuid unless contactable_uuid
  end

  def self.categories_opt
    CATEGORIES_OPT
  end

  def self.category_map
    CATEGORIES_MAP
  end

end
