class Admin::UserMobileOptionsController < AdminController
  before_action :require_selected_account

  def edit
    @option = UserMobileOption.find(params[:id])
  end

  def update
    @option = UserMobileOption.find(params[:id])
    if @option.update_attributes(options_params)
      rw_redirect_back
    else
      render "edit"
    end
  end

  private

  def options_params
    params.require(:user_mobile_option).permit!
  end

end
