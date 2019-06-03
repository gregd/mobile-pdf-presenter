class UsersController < ClientController
  include PermControl
  before_action :dictionaries_for_create, only: %i(new create)
  before_action :check_max_count, only: %i(new create)

  def index
    @users = User.active.order("last_name, first_name")
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User::Register.new
    @user.emp_position_id = params[:emp_position_id]
  end

  def create
    @user = User::Register.new(register_params)
    if @user.save
      flash[:success] = "Nowy użytkownik dodany."
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
      flash[:success] = "Zmiany w danych użytkownika zapisane."
      rw_redirect_back
    else
      render :edit
    end
  end

  def destroy
    @user = User::AsEdit.find(params[:id])
    @user.deactivate
    @user.save!
    flash[:success] = "Konto użytkownika #{@user.full_name} dezaktywowane."
    redirect_to users_path
  end

  private

  def dictionaries_for_create
    @app_roles = Account.current.app_roles.pluck(:name, :id)

    @emps = EmpPosition.
      order("path").
      map {|e| ["#{'- ' * (e.depth - 1)} #{e.name}", e.id] }
  end

  def register_params
    params.require(:user_register).
      permit(:first_name, :last_name, :email, :phone, :app_role_id, :emp_position_id, :send_invitation)
  end

  def user_params
    params.require(:user).
      permit(:first_name, :last_name, :email, :phone)
  end

  def check_max_count
    unless User::Register.can_add_new?
      flash[:error] = "Nie możesz dodać więcej użytkowników. Musisz przejść na wyższy abonament."
      rw_redirect_back
    end
  end

end
