# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  first_name      :string
#  last_name       :string
#  email           :string
#  phone           :string
#  password_digest :string
#  billable        :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#

class User < ApplicationRecord
  include AccountScoped
  include WithPresenter

  has_one :user_web_option
  has_one :user_mobile_option
  has_many :user_roles, -> { active }
  has_one :home_user_address, -> { active.home }, class_name: "UserAddress", dependent: :destroy

  scope :active, -> { where("users.deleted_at IS NULL") }

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def active?
    ! deleted_at
  end

  def notification_phone
    phone
  end

end
