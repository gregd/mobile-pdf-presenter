# == Schema Information
#
# Table name: persons
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  uuid            :uuid
#  collab          :string
#  person_title_id :integer
#  first_name      :string
#  last_name       :string
#  unknown_name    :boolean          default(FALSE), not null
#  searchable_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  lock_version    :integer          default(0)
#  master_id       :integer
#

class Person < ApplicationRecord
  include AccountScoped
  include WithPresenter

  belongs_to :person_title
  has_many :person_jobs, -> { active }
  has_many :all_person_jobs, class_name: "PersonJob", dependent: :destroy
  has_one :main_person_job, -> { active.main_job }, class_name: "PersonJob"
  has_one :main_org_unit, through: :main_person_job, source: :org_unit

  has_many :all_contacts, class_name: "Contact", as: :contactable, dependent: :destroy
  has_many :contacts, -> { active }, as: :contactable
  has_many :all_taggings, class_name: "Tagging", as: :taggable, dependent: :destroy
  has_many :taggings, -> { active.includes(:tag) }, as: :taggable

  has_many :activity_participants, -> { active }
  has_many :activity_visits, -> { active }, through: :activity_participants, source: :activity, source_type: "ActivityVisit"

  scope :active, -> { where("persons.deleted_at IS NULL") }

  def grouped_taggings
    Tagging::AsDict.grouped_for(self)
  end

end
