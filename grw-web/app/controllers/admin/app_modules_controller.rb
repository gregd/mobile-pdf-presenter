class Admin::AppModulesController < AdminController

  def index
    @modules = AppModule.order("position")
  end

  def new
    @module = AppModule.new
  end

  def create
    @module = AppModule.new(app_module_params)
    if @module.save
      flash[:success] = "Moduł #{@module.name} dodany."
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @module = AppModule.find(params[:id])
    render :new
  end

  def update
    @module = AppModule.find(params[:id])
    if @module.update_attributes(app_module_params)
      rw_redirect_back
    else
      render :new
    end
  end

  private

  def app_module_params
    params.require(:app_module).permit!
  end

end
