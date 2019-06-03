class Admin::UsersController < AdminController
  before_action :require_selected_account
  before_action :dictionaries_for_create, only: %i(new create)

  def index
    @users = Account.current.users.order("last_name, first_name")
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User::Register.new
  end

  def create
    @user = User::Register.new(register_params)
    if @user.save
      flash[:success] = "User created."
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @user = User::AsEdit.find(params[:id])
  end

  def update
    @user = User::AsEdit.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "User updated."
      rw_redirect_back
    else
      render :edit
    end
  end

  def simulate
    @user = User.find(params[:id])
    token = AdminSimToken.create_for!(current_admin.id, @user.account.subdomain, @user.id)

    if Rails.env.production?
      redirect_to "https://#{@user.account.subdomain}.example.com/login/simulate?user_id=#{@user.id}&simulate_token=#{token}"
    else
      redirect_to "http://#{@user.account.subdomain}.gd.pl:3000/login/simulate?user_id=#{@user.id}&simulate_token=#{token}"
    end
  end

  private

  def dictionaries_for_create
    @app_roles = Account.current.app_roles.pluck(:name, :id)
    @emps = EmpPosition::AsDict.for_users
    @areas = GeoArea::AsDict.for_users
  end

  def register_params
    params.require(:user_register).
      permit(:first_name, :last_name, :email, :phone, :app_role_id, :emp_position_id, :geo_area_id, :send_invitation)
  end

  def user_params
    params.require(:user).
      permit(:first_name, :last_name, :email, :phone, :billable, :password, :password_confirmation)
  end

end
