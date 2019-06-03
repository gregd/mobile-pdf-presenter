class Admin::AppMenuItemsController < AdminController

  def index
    @search = AppMenuItem::Search.new(params.fetch(:app_menu_item_search, {}).permit!)
  end

  def new
    @item = AppMenuItem::AsEdit.new
    @action_groups = AppModule.order("position, id")
  end

  def create
    @item = AppMenuItem::AsEdit.new(app_menu_item_params)
    if @item.save
      rw_redirect_back
    else
      @action_groups = AppModule.order("position, id")
      render :new
    end
  end

  def edit
    @item = AppMenuItem::AsEdit.find(params[:id])
    @action_groups = AppModule.order("position, id")
    render :new
  end

  def update
    @item = AppMenuItem::AsEdit.find(params[:id])
    @item.update_attributes(app_menu_item_params)
    app_update_flash(@item) { "Menu item '#{@item.name}' updated" }

    respond_to do |format|
      format.html do
        if @item.errors.empty?
          rw_redirect_back
        else
          render :new
        end
      end
      format.js {}
    end
  end

  def groups
    search = AppMenuItem::Search.new
    render :json => search.action_groups(params[:app_module_id].to_i)
  end

  def menus
    @menu_tree = AppMenuItem::AsBuilder.whole_menu_tree
  end

  def discover
    sio = StringIO.new
    Service::AppMenu.create_items(sio)
    flash[:success] = sio.string.gsub("\n", "<br/>")
    rw_redirect_back
  end

  private

  def app_menu_item_params
    params.require(:app_menu_item).permit!
  end

end
