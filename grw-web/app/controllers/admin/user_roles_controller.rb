class Admin::UserRolesController < AdminController
  before_action :require_selected_account, :load_dictionaries

  def new
    @user_role = UserRole::AsEdit.new
    @user_role.user_id = params[:user_id]
  end

  def create
    @user_role = UserRole::AsEdit.new(user_role_params)
    if @user_role.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @user_role = UserRole::AsEdit.find(params[:id])
    render :new
  end

  def update
    @user_role = UserRole::AsEdit.find(params[:id])
    if @user_role.update_attributes(user_role_params)
      rw_redirect_back
    else
      render :new
    end
  end

  private

  def user_role_params
    params.require(:user_role).permit!
  end

  def load_dictionaries
    @app_roles = Account.current.app_roles.pluck(:name, :id)
    @emps = EmpPosition::AsDict.for_users
    @areas = GeoArea::AsDict.for_users
  end

end
