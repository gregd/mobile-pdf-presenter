# == Schema Information
#
# Table name: admin_web_options
#
#  id           :integer          not null, primary key
#  admin_id     :integer
#  per_page     :integer          default(10), not null
#  sidebar_wide :boolean          default(TRUE)
#

class AdminWebOption < ApplicationRecord
  belongs_to :admin

end
