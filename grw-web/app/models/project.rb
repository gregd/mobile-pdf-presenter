# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

class Project < ApplicationRecord
end
