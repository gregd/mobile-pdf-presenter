class TagGroupsController < ClientController
  include PermControl
  before_action :load_dictionaries

  def index
    @groups = TagGroup::AsEdit.active.order("position")
  end

  def new
    @group = TagGroup::AsEdit.new
  end

  def create
    @group = TagGroup::AsEdit.new(tag_group_params)
    if @group.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @group = TagGroup::AsEdit.find(params[:id])
    render :new
  end

  def update
    @group = TagGroup::AsEdit.find(params[:id])
    if @group.update_attributes(tag_group_params)
      rw_redirect_back
    else
      render :new
    end
  end

  def destroy
  end

  private

  def load_dictionaries
    @klasses = TagGroup::AsEdit.klasses_opt
  end

  def tag_group_params
    params.require(:tag_group).permit(
      :name, :abbr, :position, :has_uniqueness, :is_important,
      { klasses: [] })
  end

end
