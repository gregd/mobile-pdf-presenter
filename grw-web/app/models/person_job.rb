# == Schema Information
#
# Table name: person_jobs
#
#  id           :integer          not null, primary key
#  account_id   :integer
#  uuid         :uuid
#  job_title_id :integer
#  org_unit_id  :integer
#  person_id    :integer
#  person_uuid  :uuid
#  main_job     :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#  lock_version :integer          default(0)
#

class PersonJob < ApplicationRecord
  include AccountScoped
  belongs_to :job_title
  belongs_to :org_unit
  belongs_to :person

  scope :main_job, -> { where("person_jobs.main_job IS TRUE") }
  scope :active, -> { where("person_jobs.deleted_at IS NULL") }

end
