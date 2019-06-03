# == Schema Information
#
# Table name: app_permissions
#
#  id                  :integer          not null, primary key
#  app_role_id         :integer
#  app_action_group_id :integer
#  allow               :boolean          default(FALSE), not null
#

class AppPermission < ApplicationRecord
  belongs_to :app_role
  belongs_to :app_action_group

  def self.has_access?(cname, aname, role_id)
    self.has_access(cname, aname, role_id)[0]
  end

  def self.has_access(cname, aname, role_id)
    perm = select("app_permissions.*, app_menu_items.id AS app_menu_item_id").
      joins(app_action_group: :app_menu_items).
      where("app_role_id = ? AND app_menu_items.controller = ? AND app_menu_items.action = ?", role_id, cname, aname).
      order("app_menu_items.level").first

    raise "There is no AppPermission record for #{role_id}, '#{cname}', '#{aname}'" unless perm
    return perm.allow, perm.app_menu_item_id
  end

  class << self; extend Memoist; self; end.memoize :has_access

  # Workaround for Memoist lack of method to delete class level cache
  def self.clear_memoist_cache
    mm = Memoist.memoized_ivar_for(:has_access)
    if AppPermission.instance_variable_defined?(mm)
      AppPermission.remove_instance_variable(mm)
    end
  end

end
