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

class ActivityVisit < ApplicationRecord
  include AccountScoped

  belongs_to :creator, class_name: "UserRole", foreign_key: "creator_role_id"
  belongs_to :user_role
  belongs_to :org_unit
  belongs_to :address
  has_many :activity_participants, -> { active }, as: :activity
  has_many :attachments, as: :owner

  scope :active, -> { where("activity_visits.deleted_at IS NULL") }

  STAGE_PLANNED   = "planned"
  STAGE_APPROVED  = "approved"
  STAGE_REPORTED  = "reported"
  STAGE_CANCELLED = "cancelled"
  STAGES_VALUES   = ["planned", "approved", "reported", "cancelled"].freeze

  STATE_INIT      = "init"
  STATE_DRAFT     = "draft"
  STATE_VALID     = "valid"
  VALIDITY_VALUES = ["init", "draft", "valid"].frozen?

  KLASS_SINGLE = "single"
  KLASS_GROUP  = "group"

  FORM_SIMPLE = "simple"

  def state_init?
    validity_state == STATE_INIT
  end

  def state_draft?
    validity_state == STATE_DRAFT
  end

  def state_valid?
    validity_state == STATE_VALID
  end

  def stage_planned?
    activity_stage == STAGE_PLANNED
  end

  def stage_approved?
    activity_stage == STAGE_APPROVED
  end

  def stage_reported?
    activity_stage == STAGE_REPORTED
  end

  def stage_cancelled?
    activity_stage == STAGE_CANCELLED
  end

end
