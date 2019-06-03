# == Schema Information
#
# Table name: app_stat_groups
#
#  id       :integer          not null, primary key
#  position :integer
#  name     :string
#

class AppStatGroup < ApplicationRecord
  has_many :items, class_name: "AppMenuItem"

  validates :name, presence: true
  validates :position, presence: true

  before_destroy :can_destroy?

  def can_destroy?
    items.count == 0
  end

end
