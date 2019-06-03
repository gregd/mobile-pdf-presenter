# == Schema Information
#
# Table name: user_web_options
#
#  id           :integer          not null, primary key
#  account_id   :integer
#  user_id      :integer
#  per_page     :integer          default(10)
#  sidebar_wide :boolean          default(TRUE), not null
#

class UserWebOption < ApplicationRecord
  include AccountScoped
  belongs_to :user

end
