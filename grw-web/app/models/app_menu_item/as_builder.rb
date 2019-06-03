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

class AppMenuItem::AsBuilder < AppMenuItem
  include ExtendedModel

  has_many :sub_menus, class_name: "AppMenuItem::AsBuilder", foreign_key: :parent_id
  scope :visible_level, ->(level) { where("app_menu_items.visible IS TRUE AND app_menu_items.level = ?", level) }
  scope :allowed_for, ->(app_role_id) { where("app_permissions.allow IS TRUE AND app_permissions.app_role_id = ?", app_role_id).joins(app_action_group: :app_permissions) }
  default_scope { order("app_menu_items.position") }

  def self.find_items_for(app_role_id)
    @find_items_for ||= {}
    @find_items_for[app_role_id] ||= begin
      visible_level(1).allowed_for(app_role_id).map do |top_menu|
        [top_menu, top_menu.sub_menus.visible_level(2).allowed_for(app_role_id).to_a ]
      end
    end
  end

  def self.whole_menu_tree
    where("level = 1 AND visible IS TRUE").
      order("position").map do |m|

      [m,
       m.sub_menus.
         where("level = 2 AND visible IS TRUE").
         order("position").to_a]
    end
  end

end
