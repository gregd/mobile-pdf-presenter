# == Schema Information
#
# Table name: org_units
#
#  id                :integer          not null, primary key
#  account_id        :integer
#  uuid              :uuid
#  owner_id          :integer
#  collab            :string
#  name              :string
#  tax_nip           :string
#  searchable_name   :string
#  active_jobs_count :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  lock_version      :integer          default(0)
#  master_id         :integer
#

class OrgUnit < ApplicationRecord
  include AccountScoped
  include WithPresenter

  COLLAB_LEAD   = "lead"
  COLLAB_LOST   = "lost"
  COLLAB_CLIENT = "client"
  COLLAB_PAUSED = "paused"
  COLLAB_MAP = {
    COLLAB_LEAD   => "potencjalna",
    COLLAB_LOST   => "stracona",
    COLLAB_CLIENT => "aktywna",
    COLLAB_PAUSED => "zawieszona" }
  COLLAB_VALUES = COLLAB_MAP.keys.freeze

  has_one :main_org_unit_address, -> { addr_main }, class_name: "OrgUnitAddress"
  has_one :main_address, through: :main_org_unit_address, source: :address
  has_many :person_jobs, -> { active.includes(:person, :job_title) }
  has_many :persons, -> { active }, through: :person_jobs, source: :person
  has_many :contacts, -> { active }, as: :contactable
  has_many :taggings, -> { active.includes(:tag) }, as: :taggable

  has_many :activity_visits, -> { active }

  scope :active, -> { where("org_units.deleted_at IS NULL") }

  def grouped_taggings
    Tagging::AsDict.grouped_for(self)
  end

end
