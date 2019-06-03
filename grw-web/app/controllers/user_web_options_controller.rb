class UserWebOptionsController < ClientController
  include PermControl

  def update
    options = current_user.user_web_option
    options.update_attributes!(option_params)
    render :json => { result: "success" }
  end

  private

  def option_params
    params.require(:current_web_option).
      permit(:sidebar_wide, :per_page)
  end

end
