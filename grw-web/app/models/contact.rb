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

class Contact < ApplicationRecord
  include AccountScoped
  include WithPresenter
  belongs_to :contactable, polymorphic: true

  scope :active, -> { where("contacts.deleted_at IS NULL") }

  CATEGORIES_MAP = {
    "phone" => "Telefon",
    "email" => "E-mail",
    "www"   => "Strona www" }.freeze
  CATEGORIES_OPT = CATEGORIES_MAP.invert.to_a.freeze
  CATEGORIES_VALUES = CATEGORIES_MAP.keys.freeze

end
