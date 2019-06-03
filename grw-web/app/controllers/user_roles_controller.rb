class UserRolesController < ClientController
  include PermControl
  before_action :load_dictionaries

  def new
    @user_role = UserRole::AsEdit.new
    @user_role.user_id = params[:user_id]
    @user_role.emp_position_id = params[:emp_position_id]
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

  def destroy
    @user_role = UserRole::AsEdit.find(params[:id])
    raise "Cannot destroy this role" unless @user_role.can_destroy?
    @user_role.deactivate
    @user_role.save!

    flash[:success] = "Rola usunięta."
    rw_redirect_back
  end

  private

  def user_role_params
    params.require(:user_role).
      permit(:user_id, :app_role_id, :emp_position_id, :geo_area_id)
  end

  def load_dictionaries
    @app_roles = Account.current.app_roles.pluck(:name, :id)
    @emps = EmpPosition::AsDict.for_users
    @areas = GeoArea::AsDict.for_users

    @users = User.active.map {|u| [u.full_name, u.id] }
  end

end
