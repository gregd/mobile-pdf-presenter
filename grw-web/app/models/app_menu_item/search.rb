class AppMenuItem::Search < ActiveType::Object
  extend Memoist

  attribute :level, :integer
  attribute :empty_group, :boolean
  attribute :controller, :string
  attribute :app_action_group_id, :integer

  def result
    s = AppMenuItem.all
    s = s.where("level = ?", level)                               if level.present?
    s = s.where("app_action_group_id IS NULL")                    if empty_group
    s = s.where("controller LIKE ?", controller + '%')            if controller.present?
    s = s.where("app_action_group_id = ?", app_action_group_id)   if app_action_group_id.present?
    s.includes(:app_action_group).
      order("controller, action").
      group_by {|mi| mi.controller }
  end

  def levels
    [1, 2]
  end

  def menus
    AppMenuItem.where("level = 1").order("position").pluck(:name, :id)
  end

  def modules
    AppModule.order("position").pluck(:name, :id)
  end

  def stat_groups
    AppStatGroup.order("position").pluck(:name, :id)
  end

  def action_groups(module_id)
    @module_action_groups ||= begin
      a = AppActionGroup.
        order("position, id").
        pluck(:name, :id, :app_module_id).
        group_by {|a| a[2] }
      a.each_value {|aa| aa.each {|aaa| aaa.pop } }
      a
    end

    @module_action_groups[module_id] || []
  end

  memoize :result, :levels, :menus, :modules, :stat_groups
end