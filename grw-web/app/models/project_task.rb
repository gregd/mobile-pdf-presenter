# == Schema Information
#
# Table name: project_tasks
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  project_id  :integer
#  name        :string
#  description :text
#  tags        :integer          default([]), is an Array
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

class ProjectTask < ApplicationRecord
end
