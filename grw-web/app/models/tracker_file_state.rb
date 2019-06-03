# == Schema Information
#
# Table name: tracker_file_states
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  uuid           :uuid
#  user_role_id   :integer
#  trackable_type :string
#  trackable_uuid :uuid
#  trackable_id   :integer
#  tracking_id    :integer
#  page           :integer
#  position       :integer
#  progress       :integer
#  extras         :text
#  lock_version   :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#

class TrackerFileState < ApplicationRecord
  include AccountScoped
  include SyncModel
  belongs_to :tracker_file, :foreign_key => :tracking_id
  belongs_to :trackable, polymorphic: true

  scope :active, -> { where("deleted_at IS NULL") }
  scope :recent, -> { where("deleted_at IS NULL AND progress > 0").order("updated_at DESC").limit(10) }

  def other_same_trackable
    q = self.class.active.where(trackable: trackable, tracking_id: tracking_id)
    q = q.where("id != ?", self.id) unless new_record?
    q
  end

  def self.deactivate_duplicates(trackable)
    n = Time.now
    TrackerFileState.exec_sql(<<-SQL, n, n, trackable.class.name, trackable.id)
      update tracker_file_states
      set deleted_at = ?, updated_at = ?
      where id in (
        select d.id
        from (
          select
            id as id,
            row_number() over (partition by trackable_type, trackable_id, tracking_id order by updated_at desc) as num
          from tracker_file_states
          where deleted_at is null and trackable_type = ? and trackable_id = ?) d
        where d.num > 1)
    SQL
  end

end
