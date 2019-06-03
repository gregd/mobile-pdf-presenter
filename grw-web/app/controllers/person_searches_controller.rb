class PersonSearchesController < ClientController
  include PermControl

  def index
    load_dictionaries

    @search = PersonSearch.get_for(current_user_role)

    if params[:mass_print]
      redirect_to mass_print_path(person_search_id: @search.id)
      return
    end

    if params[:add_tag_id]
      @search.per_page = nil
      persons = @search.execute
      @search.reload

      tag = Tag.find(params[:add_tag_id].to_i)
      added = Tagging::AsEdit.add_to(current_user_role, persons, tag)
      flash[:success] = "Znacznik #{tag.abbr} dodany do #{added} osób."
    end

    if params[:person_search]
      @search.set_params(search_params)
      @search.page = params[:page]
      @search.save!

    elsif params[:page]
      @search.page = params[:page]
      @search.save!
    end

    if @search.do_search
      @persons = @search.execute
    end
  end

  def destroy
    s = PersonSearch.find(params[:id])
    s.destroy!
    redirect_to person_searches_path
  end

  private

  def load_dictionaries
    @collab_list = OrgUnit::AsDict.collab_opt
    @tags = Tag::AsDict.for_klass("Person")
    @wo_tags = Tag::AsDict.for_klass("Person")
    @ou_tags = Tag::AsDict.for_klass("OrgUnit")
  end

  def search_params
    params.require(:person_search).permit(
      :query, :collab,
      { tags_ids: [] }, { wo_tags_ids: [] }, { ou_tags_ids: [] } )
  end

end
