class Admin::AppPermissionsController < AdminController
  before_action :load_dictionaries, only: %i(index)

  def index
    if params[:modules_ids]
      @selected_modules = params[:modules_ids].map(&:to_i)
    else
      @selected_modules = [ @modules.first[1] ]
    end

    @roles = AppRole.joins(:app_role_set)
    if params[:role_set_id].present?
      @selected_role_set_id = params[:role_set_id].to_i
      @roles = @roles.where("app_role_set_id = ?", @selected_role_set_id)
    end
    @roles = @roles.reorder("app_roles.position, app_role_sets.position").to_a

    @permissions = AppPermission.
      includes([{ app_action_group: :app_module }, { app_role: :app_role_set }]).
      references([{ app_action_group: :app_module }, { app_role: :app_role_set }]).
      where("app_action_groups.app_module_id IN (?)", @selected_modules).
      order("app_modules.name, app_action_groups.name, app_roles.position, app_role_sets.position")

    @permissions = @permissions.where("app_roles.app_role_set_id IN (?)", @selected_role_set_id) if @selected_role_set_id

    @permissions = @permissions.
      group_by {|perm| perm.app_action_group.app_module.name }.
      map {|m, arr| [m, arr.group_by {|perm| perm.app_action_group.name }] }.to_h
  end

  def update
    @perm = AppPermission.find(params[:id])
    if @perm.update_attributes(app_permissions_params)
      AppPermission.clear_memoist_cache
      AppRole::AsEdit.update_capabilities
    end
    app_update_flash(@perm) { "Zmiany w '#{@perm.app_action_group.name}/#{@perm.app_role.name}' zapisane." }
  end

  private

  def load_dictionaries
    @role_sets = AppRoleSet.active.map {|s| [s.name, s.id] }
    @modules = AppModule.order("position").pluck(:name, :id)
  end

  def app_permissions_params
    params.require(:app_permission).permit!
  end

end
