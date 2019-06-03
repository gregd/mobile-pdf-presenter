class ActivityProductGroupsController < ClientController
  include PermControl
  before_action :load_dictionaries

  def index
    @groups = ActivityProductGroup::AsEdit.active.order("position")
  end

  def new
    @group = ActivityProductGroup::AsEdit.new
  end

  def create
    @group = ActivityProductGroup::AsEdit.new(group_params)
    if @group.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @group = ActivityProductGroup::AsEdit.find(params[:id])
    render :new
  end

  def update
    @group = ActivityProductGroup::AsEdit.find(params[:id])
    if @group.update_attributes(group_params)
      rw_redirect_back
    else
      render :new
    end
  end

  def destroy
  end

  private

  def load_dictionaries
    @klasses = ActivityProductGroup::AsEdit.klasses_opt
  end

  def group_params
    params.require(:activity_product_group).permit(
      :name, :abbr, :position, { klasses: [] })
  end

end
