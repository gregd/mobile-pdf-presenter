class Admin::AccountConfigsController < AdminController

  def edit
    @config = AccountConfig.find(params[:id])
  end

  def update
    @config = AccountConfig.find(params[:id])
    if @config.update_attributes(config_params)
      flash[:success] = "Zmiany zapisane"
      rw_redirect_back
    else
      render :edit
    end
  end

  private

  def config_params
    params.require(:account_config).permit!
  end

end
