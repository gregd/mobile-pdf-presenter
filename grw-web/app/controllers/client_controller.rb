class ClientController < ApplicationController
  before_action :authorize_account, :authorize_user, :load_user_role, :authorize_access
  rescue_from Grw::ForbiddenError, :with => :handle_forbidden

  private

  def authorize_account
    sd = request.subdomain
    if sd.blank? && Rails.env.development?
      sd = "grw"
      logger.info "dev set account: #{sd}"
    end
    account = Account.find_active(sd)
    if account
      Account.set_current(account)
      return true
    end

    redirect_to "/no_account?subdomain=#{sd}"
    false
  end

  def authorize_user
    if session[:user_id] && session[:company] && Account.current.subdomain == session[:company]
      user = User::AsLogin.find_active(session[:user_id])
      if user
        @current_user = user.becomes(User)

        request.env["exception_notifier.exception_data"] = {
          subdomain: Account.current.subdomain,
          user_email: user.email }
        return true
      end
    end

    # A user with active session might be deactivated so have to reset the session user_id.
    # Otherwise there will be redirect loop because of authorize call from login page.
    session[:user_id] = nil

    respond_to do |format|
      format.html do
        session[:jumpto] = request.parameters
        redirect_to new_login_path
      end
      format.js { render status: 401, json: { result: 'failed' } }
    end

    false
  end

  def set_user_logged(user)
    session[:company] = Account.current.subdomain
    session[:user_id] = user.id
    session[:user_role_id] = user.default_user_role.id
  end

  def set_user_role(role, reset_dependent = true)
    session[:user_role_id] = role.id

    if reset_dependent
      # Have to reset these parameters because some of them are specific to given user role.
      session[:cal_owner_id] = nil
    end
  end

  def load_user_role
    if params[:require_user_role_id]
      new_role = current_user.user_roles.where(id: params[:require_user_role_id]).first
      raise Grw::ForbiddenError unless new_role
      set_user_role(new_role)
    end

    all_roles = current_user.user_roles.to_a
    @current_user_role = all_roles.detect {|ur| ur.id == session[:user_role_id] }
    UserRole.set_current(@current_user_role)

    raise Grw::ForbiddenError unless @current_user_role
    true
  end

  def authorize_access
    access, @app_menu_item_id = AppPermission.has_access(self.controller_path,
                                                         self.action_name,
                                                         current_user_role.app_role_id)
    raise Grw::NotFoundError if @app_menu_item_id.nil?
    raise Grw::ForbiddenError unless access
    true
  end

  def handle_forbidden(ex)
    if params[:update_position] == 'yes' && current_user_role
      # update_position is only set when changing profile. Don't generate exception because
      # accessible page in first profile might be not available in second one.
      redirect_to dashboard_path
    else
      raise ex
    end
  end

  def current_user
    @current_user
  end
  helper_method :current_user

  def current_user_role
    @current_user_role
  end
  helper_method :current_user_role

  def current_web_option
    current_user ? current_user.user_web_option : nil
  end
  helper_method :current_web_option

end