# == Schema Information
#
# Table name: app_permissions
#
#  id                  :integer          not null, primary key
#  app_role_id         :integer
#  app_action_group_id :integer
#  allow               :boolean          default(FALSE), not null
#

class AppPermission::AsEdit < AppPermission
  include ExtendedModel

  def self.find_or_create(ar, ag, al)
    perm = where(app_role_id: ar.id,
                 app_action_group_id: ag.id).first
    return perm, false if perm
    perm = create(app_role: ar,
                  app_action_group: ag,
                  allow: al)
    return perm, true
  end

  def self.copy_perms(from_role_id, to_role_id)
    exec_sql <<-SQL, to_role_id, from_role_id
      INSERT INTO app_permissions (app_role_id, app_action_group_id, allow)
        SELECT ?, app_action_group_id, allow
        FROM app_permissions
        WHERE app_role_id = ?
    SQL
  end

  def self.init_perms(role_id)
    exec_sql <<-SQL, role_id
      DELETE FROM app_permissions WHERE app_role_id = ?
    SQL
    exec_sql <<-SQL, role_id
      INSERT INTO app_permissions (app_role_id, app_action_group_id, allow)
        SELECT ?, id, FALSE
        FROM app_action_groups
    SQL
  end

  def self.grant_all_for_all
    update_all("allow = TRUE")
  end

  def self.update_matrix(sio)
    old_ids = all.pluck(:id)
    valid_ids = []
    new_ids = []
    new_ag = []
    sio.puts "There are already #{old_ids.size} action records."
    AppRole.all.each do |ur|
      AppActionGroup.all.each do |ag|
        an, is_new = find_or_create(ur, ag, false)
        valid_ids << an.id
        if is_new
          new_ids << an.id
          new_ag << ag
        end
      end
    end
    sio.puts "Added #{new_ids.size} action records."

    to_delete = old_ids - valid_ids
    AppPermission.delete(to_delete)
    sio.puts "Deleted #{to_delete.size} action records."

    new_ag.uniq!
    sio.puts "New AppActionGroup records #{new_ag.size}."
    new_ag.each do |ag|
      sio.puts "Module: #{ag.app_module.name} Name: #{ag.name}"
    end
  end

end
