# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  subdomain        :string
#  company          :string
#  account_plan_id  :integer
#  app_role_set_id  :integer
#  geo_partition_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

class Account < ApplicationRecord
  belongs_to :account_plan
  belongs_to :app_role_set
  belongs_to :geo_partition
  has_many :app_roles, -> { active }, primary_key: :app_role_set_id, foreign_key: :app_role_set_id
  has_one :config, -> { active }, class_name: "AccountConfig"
  has_many :users, -> { active }

  scope :active, -> { where("accounts.deleted_at IS NULL") }

  def has_geo_structure?
    !! geo_partition_id
  end

  def self.find_active(subdomain)
    self.active.where(subdomain: subdomain).first
  end

  def self.set_current(a)
    RequestStore.store[:current_account] = a
  end

  def self.current
    RequestStore.store[:current_account]
  end

end
