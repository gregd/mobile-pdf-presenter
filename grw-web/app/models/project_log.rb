# == Schema Information
#
# Table name: project_logs
#
#  id                    :integer          not null, primary key
#  account_id            :integer
#  uuid                  :uuid
#  user_role_id          :integer
#  project_task_id       :integer
#  location_summary_uuid :uuid
#  location_summary_id   :integer
#  comments              :text
#  whole_day             :boolean
#  seconds               :integer
#  begin_at              :datetime
#  end_at                :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  deleted_at            :datetime
#

class ProjectLog < ApplicationRecord

end
