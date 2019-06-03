# == Schema Information
#
# Table name: account_plans
#
#  id                :integer          not null, primary key
#  position          :integer
#  name              :string
#  description       :text
#  min_users         :integer
#  max_users         :integer
#  max_emp_positions :integer
#  monthly_user_fee  :decimal(12, 2)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#

class AccountPlan < ApplicationRecord
  has_many :accounts

  validates :name, presence: true
  validates :description, presence: true
  validates :min_users, presence: true
  validates :max_users, presence: true
  validates :max_emp_positions, presence: true
  validates :monthly_user_fee, presence: true

  scope :active, -> { where("deleted_at IS NULL") }

end
