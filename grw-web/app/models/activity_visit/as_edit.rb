# == Schema Information
#
# Table name: activity_visits
#
#  id                        :integer          not null, primary key
#  account_id                :integer
#  uuid                      :uuid
#  creator_role_id           :integer
#  user_role_id              :integer
#  org_unit_id               :integer
#  address_id                :integer
#  address_uuid              :uuid
#  validity_state            :string
#  klass                     :string
#  activity_on               :date
#  begin_at                  :datetime
#  end_at                    :datetime
#  has_time                  :boolean          default(FALSE), not null
#  activity_stage            :string
#  planned_at                :datetime
#  approved_at               :datetime
#  reported_at               :datetime
#  cancelled_at              :datetime
#  missed_at                 :datetime
#  comments                  :text
#  form_category             :string
#  products_ids              :integer          default([]), not null, is an Array
#  extra_attrs               :jsonb            not null
#  has_checkin               :boolean          default(FALSE), not null
#  active_participants_count :integer          default(0), not null
#  active_attachments_count  :integer          default(0), not null
#  user_updated_at           :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  deleted_at                :datetime
#  lock_version              :integer          default(0)
#

class ActivityVisit::AsEdit < ActivityVisit
  include ExtendedModel

  protect_account_forgery :user_role, :org_unit, :address

  validates :validity_state, presence: true, inclusion: VALIDITY_VALUES
  validates :activity_stage, presence: true, inclusion: STAGES_VALUES
  validates :uuid, presence: true
  validates :creator_role_id, presence: true
  validates :user_role_id, presence: true
  validates :org_unit_id, presence: true
  validates :address_id, presence: true
  validates :address_uuid, presence: true
  validates :klass, presence: true
  validates :activity_on, presence: true
  validates :has_time, inclusion: [true, false]

  before_validation :set_defaults

  def set_defaults
    self.has_time = false               if has_time.nil?
    self.uuid = SecureRandom.uuid       unless uuid
    self.validity_state = STATE_INIT    unless validity_state
    self.klass = KLASS_SINGLE           unless klass
    self.form_category = FORM_SIMPLE    unless form_category
    self.user_updated_at = Time.now     unless user_updated_at

    if address_uuid.nil? && address_id
      self.address_uuid = address.uuid
    end

    if ! has_time && activity_on && begin_at.nil?
      self.begin_at = activity_on.beginning_of_day
      self.end_at   = activity_on.end_of_day
    end
  end

end
