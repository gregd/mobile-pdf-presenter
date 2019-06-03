class OrgUnitSearchesController < ClientController
  include PermControl

  def index
    load_dictionaries

    @search = OrgUnitSearch.get_for(current_user_role)

    if params[:mass_print]
      redirect_to mass_print_path(org_unit_search_id: @search.id)
      return
    end

    if params[:add_tag_id]
      @search.per_page = nil
      units = @search.execute
      @search.reload

      tag = Tag.find(params[:add_tag_id].to_i)
      added = Tagging::AsEdit.add_to(current_user_role, units, tag)
      flash[:success] = "Znacznik #{tag.abbr} dodany do #{added} firm."
    end

    if params[:org_unit_search]
      @search.set_params(search_params)
      @search.page = params[:page]
      @search.save!

    elsif params[:page]
      @search.page = params[:page]
      @search.save!
    end

    if @search.do_search
      @org_units = @search.execute
    end
  end

  def destroy
    s = OrgUnitSearch.find(params[:id])
    s.destroy!
    redirect_to org_unit_searches_path
  end

  private

  def load_dictionaries
    @collab_list = OrgUnit::AsDict.collab_opt
    @tags = Tag::AsDict.for_klass("OrgUnit")
    @wo_tags = Tag::AsDict.for_klass("OrgUnit")
  end

  def search_params
    params.require(:org_unit_search).permit(
      :query, :name, :city, :street, :collab,
      { cities: [] }, { streets: [] }, { tags_ids: [] }, { wo_tags_ids: [] })
  end

end
