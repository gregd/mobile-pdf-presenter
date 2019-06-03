# == Schema Information
#
# Table name: app_role_sets
#
#  id          :integer          not null, primary key
#  position    :integer
#  global      :boolean
#  name        :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#  abbr        :string
#

class AppRoleSet < ApplicationRecord
  has_many :app_roles

  validates :position, presence: true
  validates :global, presence: true
  validates :name, presence: true
  validates :description, presence: true

  scope :active, -> { where("app_role_sets.deleted_at IS NULL") }
  scope :global, -> { where("app_role_sets.global IS TRUE") }

  def has_clients?
    abbr.include?("C")
  end

  def self.presenter_set
    where(abbr: "P").first
  end

  def self.locations_set
    where(abbr: "L").first
  end

  def self.presenter_locations_set
    where(abbr: "PL").first
  end

  def self.clients_set
    where(abbr: "CPL").first
  end

end
