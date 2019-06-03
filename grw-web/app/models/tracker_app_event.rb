# == Schema Information
#
# Table name: tracker_app_events
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  uuid             :uuid
#  mobile_device_id :integer
#  user_role_id     :integer
#  person_id        :integer
#  institution_id   :integer
#  app_version      :integer
#  screen           :string
#  category         :string
#  action           :string
#  label            :string
#  value            :integer
#  created_at       :datetime
#

class TrackerAppEvent < ApplicationRecord
  include AccountScoped
  include SyncModel
  belongs_to :user_role
  belongs_to :mobile_device

end
