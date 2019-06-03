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

class PersonJob::AsEdit < PersonJob
  include ExtendedModel

  validates :uuid, presence: true
  validates :job_title_id, presence: true
  validates :org_unit_id, presence: true
  validates :person_id, presence: true
  validates :person_uuid, presence: true
  validates :main_job, inclusion: { in: [ true, false ] }

  protect_account_forgery :job_title, :org_unit, :person

  before_validation :set_defaults

  def set_defaults
    self.uuid = SecureRandom.uuid unless uuid
    self.person_uuid = person.uuid unless person_uuid
  end

end
