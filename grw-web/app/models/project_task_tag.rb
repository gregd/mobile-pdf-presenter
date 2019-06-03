# == Schema Information
#
# Table name: project_task_tags
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  name           :string
#  description    :text
#  cap_sick_leave :boolean
#  cap_vacation   :boolean
#  cap_work       :boolean
#  cap_field      :boolean
#  cap_office     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#

class ProjectTaskTag < ApplicationRecord
end
