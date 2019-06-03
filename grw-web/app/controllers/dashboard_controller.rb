class DashboardController < ClientController
  include PermControl

  def index
    @admin_role = current_user_role.app_role.user_admin_role
    @mobile_app = current_user_role.app_role.cap_mobile_app
  end

end
