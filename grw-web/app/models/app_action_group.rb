# == Schema Information
#
# Table name: app_action_groups
#
#  id            :integer          not null, primary key
#  app_module_id :integer
#  position      :integer
#  name          :string
#  description   :string
#

class AppActionGroup < ApplicationRecord
  belongs_to :app_module
  has_many :app_menu_items
  has_many :app_permissions

  validates :app_module_id, presence: true
  validates :name, presence: true

  before_destroy :check_menu_items

  def can_destroy?
    ! new_record? && app_menu_items.count == 0
  end

  def check_menu_items
    unless can_destroy?
      raise "Cannot delete action group which has assigned app menu item objects."
    end
  end

end
