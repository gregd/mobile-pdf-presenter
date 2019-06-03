class Admin::AppActionGroupsController < AdminController
  before_action :load_dictionaries

  def index
    @selected_id = params[:app_module_id].present? ? params[:app_module_id].to_i : AppModule.first.id

    @groups = AppActionGroup.
      where(app_module_id: @selected_id).
      order("app_module_id, position, id").to_a
  end

  def create
    @group = AppActionGroup.new(app_action_group_params)
    if @group.save
      flash[:success] = "Grupa '#{@group.name}' dodana."
      pause_growlyflash
      render :js => "GrwUtils.reload();"
    else
      # template
    end
  end

  def update
    @group = AppActionGroup.find(params[:id])
    @group.update_attributes(app_action_group_params)
    render :create
  end

  def destroy
    group = AppActionGroup.find(params[:id])
    group.destroy
    flash[:success] = "Grupa '#{group.name}' usunięta"
    pause_growlyflash
    render :js => "GrwUtils.reload();"
  end

  private

  def app_action_group_params
    params.require(:app_action_group).permit!
  end

  def load_dictionaries
    @modules = AppModule.order("position").pluck(:name, :id)
    @new_group = AppActionGroup.new
  end

end
