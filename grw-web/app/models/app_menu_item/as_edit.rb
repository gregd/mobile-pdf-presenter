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

class AppMenuItem::AsEdit < AppMenuItem
  include ExtendedModel
  validates :position, presence: true
  validates :level, presence: true, inclusion: [1, 2]
  validates :app_action_group_id, presence: true
  validates :stat_name, :presence => true, :if => Proc.new { |mi| mi.app_stat_group_id.present? }

  normalize_attributes :position, :name, :controller, :action, :icon_name, :stat_name

  def self.find_or_create(cn, ac, level)
    # Exclude top level menus, they might have the same controller name.
    mi = where(controller: cn, action: ac).where("level != 1").first
    return mi, false if mi

    mi = create!(:controller => cn,
                 :action     => ac,
                 :name       => ac.try(:humanize),
                 :level      => level,
                 :position   => (top_for(cn, :position) || 0) + 10,
                 :parent_id  => top_for(cn, :parent_id),
                 :app_action_group_id => top_for(cn, :app_action_group_id) || AppActionGroup.first.id)
    return mi, true
  end

  def self.create_items(sio, klasses_actions)
    old_ids = where("level > 1").pluck(:id)
    valid_ids = []
    new_ids = []
    sio.puts "There are already #{old_ids.size} menu items records."

    klasses_actions.each do |sa|
      mi, is_new = find_or_create(sa[:controller], sa[:action], 2)
      valid_ids << mi.id
      if is_new
        new_ids << mi.id
        sio.puts "Adding: #{sa[:controller]} #{sa[:name]}"
      end
    end

    sio.puts "Added #{new_ids.size} menu items records."
    to_delete = old_ids - valid_ids
    delete(to_delete)
    sio.puts "Deleted #{to_delete.size} menu items records."
  end

  private

  def self.top_for(controller, col)
    actions = where("controller = ? AND #{col} IS NOT NULL", controller).to_a
    return nil if actions.empty?
    sums = Hash.new(0)
    actions.each {|a| sums[a.send(col)] += 1 }
    sums.to_a.max_by {|a| a[1] }[0]
  end

end
