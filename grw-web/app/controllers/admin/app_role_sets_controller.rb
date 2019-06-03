class Admin::AppRoleSetsController < AdminController

  def index
    @sets = AppRoleSet.order("position")
  end

  def new
    @set = AppRoleSet.new
  end

  def create
    @set = AppRoleSet.new(set_params)
    if @set.save
      flash[:success] = "AppRoleSet #{@set.name} dodany."
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @set = AppRoleSet.find(params[:id])
    render :new
  end

  def update
    @set = AppRoleSet.find(params[:id])
    if @set.update_attributes(set_params)
      rw_redirect_back
    else
      render :new
    end
  end

  private

  def set_params
    params.require(:app_role_set).permit!
  end

end
