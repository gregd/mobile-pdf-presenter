class TaggingsController < ClientController
  include PermControl

  def edit_group
    @taggable = Tagging::AsEdit.load_taggable(params[:taggable_type], params[:taggable_id])
    @group = TagGroup.find(params[:tag_group_id])

    @tags = @group.tags.order("position").map {|t| [t.name, t.id]}
    @selected = @taggable.taggings.map(&:tag_id)
  end

  def update_group
    @taggable = Tagging::AsEdit.load_taggable(params[:taggable_type], params[:taggable_id])
    @group = TagGroup.find(params[:tag_group_id])

    Tagging::AsEdit.sync_taggings(current_user_role, @taggable, @group, params_tags_ids)
    rw_redirect_back
  end

  private

  def params_tags_ids
    if @group.has_uniqueness
      [ params.fetch(:tags_ids)&.to_i ]
    else
      params.fetch(:tags_ids, []).map {|v| v.to_i }
    end
  end

end
