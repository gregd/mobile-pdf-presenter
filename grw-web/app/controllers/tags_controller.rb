class TagsController < ClientController
  include PermControl
  before_action :load_dictionaries

  def index
    @tags = Tag::AsEdit.active.order("tag_group_id, position")
  end

  def new
    @tag = Tag::AsEdit.new
    @tag.tag_group_id = params[:tag_group_id]
  end

  def create
    @tag = Tag::AsEdit.new(tag_params)
    if @tag.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @tag = Tag::AsEdit.find(params[:id])
    render :new
  end

  def update
    @tag = Tag::AsEdit.find(params[:id])
    if @tag.update_attributes(tag_params)
      rw_redirect_back
    else
      render :new
    end
  end

  def move
    @tag = Tag::AsEdit.find(params[:id])
    case params[:direction]
      when "top"
        @tag.move_to_top
      when "higher"
        @tag.move_higher
      when "lower"
        @tag.move_lower
      when "bottom"
        @tag.move_to_bottom
    end
    rw_redirect_back
  end

  def destroy

  end

  private

  def load_dictionaries
    @groups = TagGroup::AsDict.all_groups
  end

  def tag_params
    params.require(:tag).permit(
      :name, :abbr, :position, :default_tag, :tag_group_id, :color, :description)
  end

end
