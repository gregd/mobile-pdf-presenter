# == Schema Information
#
# Table name: app_menu_items
#
#  id                  :integer          not null, primary key
#  parent_id           :integer
#  position            :integer
#  level               :integer
#  app_action_group_id :integer
#  visible             :boolean          default(FALSE), not null
#  name                :string
#  controller          :string
#  action              :string
#  icon_name           :string
#  app_stat_group_id   :integer
#  stat_name           :string
#

class AppMenuItem < ApplicationRecord
  belongs_to :app_action_group
  belongs_to :parent_menu, class_name: "AppMenuItem", foreign_key: :parent_id

  def top_menu_id
    self.parent_id
  end

end
