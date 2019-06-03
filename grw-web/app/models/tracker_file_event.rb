# == Schema Information
#
# Table name: tracker_file_events
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  uuid             :uuid
#  user_role_id     :integer
#  mobile_device_id :integer
#  trackable_type   :string
#  trackable_uuid   :string
#  trackable_id     :integer
#  tracking_id      :integer
#  page             :integer
#  beginning        :integer
#  duration         :integer
#  created_at       :datetime
#

class TrackerFileEvent < ApplicationRecord
  include AccountScoped
  include SyncModel
  belongs_to :user_role
  belongs_to :mobile_device
  belongs_to :tracker_file, :foreign_key => :tracking_id

end
