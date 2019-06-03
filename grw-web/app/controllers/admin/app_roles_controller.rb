class Admin::AppRolesController < AdminController
  before_action :load_dictionaries

  def index
    @app_roles = AppRole.all

    if params[:role_set_id].present?
      @selected_role_set_id = params[:role_set_id].to_i
      @app_roles = @app_roles.where("app_role_set_id = ?", @selected_role_set_id)
    end
  end

  def new
    @role = AppRole::AsEdit.new
  end

  def create
    @role = AppRole::AsEdit.new(app_role_params)
    if @role.save
      flash[:success] = "AppRole #{@role.name} dodana."
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @role = AppRole::AsEdit.find(params[:id])
    render :new
  end

  def update
    @role = AppRole::AsEdit.find(params[:id])
    if @role.update_attributes(app_role_params)
      rw_redirect_back
    else
      render :new
    end
  end

  private

  def load_dictionaries
    @role_sets = AppRoleSet.active.pluck(:name, :id)
  end

  def app_role_params
    params.require(:app_role).permit!
  end

end
