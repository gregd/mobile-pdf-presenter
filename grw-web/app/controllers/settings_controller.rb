class SettingsController < ClientController
  include PermControl

  def index
    @user = current_user
    @roles = current_user.user_roles.order("user_position")
  end

end
