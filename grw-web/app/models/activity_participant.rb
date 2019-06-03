# == Schema Information
#
# Table name: activity_participants
#
#  id            :integer          not null, primary key
#  account_id    :integer
#  uuid          :uuid
#  person_uuid   :uuid
#  person_id     :integer
#  activity_uuid :uuid
#  activity_id   :integer
#  activity_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  lock_version  :integer          default(0)
#

class ActivityParticipant < ApplicationRecord
  include AccountScoped

  belongs_to :person
  belongs_to :activity, polymorphic: true

  scope :active, -> { where("activity_participants.deleted_at IS NULL") }

  before_validation :set_defaults

  def set_defaults
    self.uuid = SecureRandom.uuid       unless uuid
    self.person_uuid = person.uuid      unless person_uuid
    self.activity_uuid = activity.uuid  unless activity_uuid
  end

end
