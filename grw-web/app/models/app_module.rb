# == Schema Information
#
# Table name: app_modules
#
#  id       :integer          not null, primary key
#  position :integer
#  name     :string
#

class AppModule < ApplicationRecord
  has_many :app_action_groups

  validates :position, presence: true
  validates :name, presence: true

end
