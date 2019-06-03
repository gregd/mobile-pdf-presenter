class AdminController < ApplicationController
  layout "admin"
  before_action :authorize_admin

  private

  def authorize_admin
    if session[:admin_id]
      admin = Admin.where(id: session[:admin_id]).first
      if admin
        @current_admin = admin
        @show_production_warning = Rails.env.production?
        return true
      end
    end

    reset_session
    respond_to do |format|
      format.html { redirect_to new_admin_login_path }
      format.js { render status: 401, json: { result: 'failed' } }
    end
  end

  def current_admin
    @current_admin
  end
  helper_method :current_admin

  def current_web_option
    current_admin ? current_admin.admin_web_option : nil
  end
  helper_method :current_web_option

  def require_selected_account
    if session[:selected_account_id]
      account = Account.find(session[:selected_account_id])
      Account.set_current(account)
    else
      redirect_to admin_accounts_path, warning: "Wymagane konto"
    end
  end

end