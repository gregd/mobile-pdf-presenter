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

class OrgUnit::AsEdit < OrgUnit
  include ExtendedModel

  validates :uuid, presence: true
  validates :name, presence: true

  before_validation :set_defaults, :normalize_fields

  def set_defaults
    self.uuid = SecureRandom.uuid unless uuid
  end

  def normalize_fields
    if name_changed?
      self.searchable_name = RwStringExt.simplify(name)
    end
  end

  def deactivate!
    OrgUnit.transaction do
      person_jobs.each do |pj|
        pj.person.deleted_at = Time.now
        pj.person.save!
        pj.deleted_at = Time.now
        pj.save!
      end
      self.deleted_at = Time.now
      self.save!
    end
  end

end
