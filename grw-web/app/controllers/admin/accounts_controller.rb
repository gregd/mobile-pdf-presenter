class Admin::AccountsController < AdminController
  before_action :load_dictionaries, except: %i(index)

  def index
    @accounts = Account.all.order(:subdomain)
  end

  def new
    plan = AccountPlan.find(@plans.first[1])

    @account = Account::Register.new
    @account.account_plan_id = plan.id
  end

  def create
    @account = Account::Register.new(account_params)
    if @account.save
      flash[:success] = "Account #{@account.company} created"
      rw_redirect_back
    else
      render :new
    end
  end

  def show
    @account = Account.find(params[:id])
    @config = @account.config
    @host_addr = request.host_with_port.gsub("#{request.subdomain}.", "")
  end

  def select
    @account = Account.find(params[:id])
    session[:selected_account_id] = @account.id
    flash[:notice] = "Wybrane #{@account.subdomain} konto"
    redirect_to admin_users_path
  end

  def destroy
    @account = Account.find(params[:id])
    Account::Cleaner.remove_account!(@account.id)
    flash[:success] = "Konto #{@account.company} zostało usunięte"
    redirect_to admin_accounts_path
  end

  private

  def account_params
    params.require(:account_register).
      permit(:account_plan_id, :app_role_set_id, :emp_template_id, :geo_template_id, :company, :subdomain,
             :first_name, :last_name, :phone, :email, :password, :password_confirmation)
  end

  def load_dictionaries
    @plans = AccountPlan.active.order(:position).pluck(:name, :id)
    @emp_templates = EmpPosition::AsStart.templates
    @geo_templates = GeoArea::AsStart.templates
    @role_sets = AppRoleSet.active.map {|s| ["#{s.name}#{s.global? ? '' : ' (NG)'}", s.id] }
  end

end
