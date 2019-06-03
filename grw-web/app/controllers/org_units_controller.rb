class OrgUnitsController < ClientController
  include PermControl
  before_action :load_dictionaries, except: %i(show destroy)

  def show
    @org_unit = OrgUnit.find(params[:id])
    @visits = @org_unit.activity_visits.to_a
  end

  def new
    @register = OrgUnit::Register.new
  end

  def create
    @register = OrgUnit::Register.new(register_params)
    @register.modifier_user_role = current_user_role

    if @register.save
      redirect_to org_unit_path(@register.id)
    else
      render :new
    end
  end

  def edit
    @org_unit = OrgUnit.find(params[:id])
  end

  def update
    @org_unit = OrgUnit.find(params[:id])
    if @org_unit.update_attributes(update_params)
      rw_redirect_back
    else
      render :edit
    end
  end

  def destroy
    @org_unit = OrgUnit::AsEdit.find(params[:id])
    @org_unit.deactivate!
    redirect_to org_unit_searches_path
  end

  private

  def load_dictionaries
    @collab_list = OrgUnit::AsDict.collab_opt
    @job_titles = JobTitle::AsDict.list
    @person_titles = PersonTitle::AsDict.list
    @org_unit_tag_groups = TagGroup::AsDict.groups_with_tags("OrgUnit")
    @person_tag_groups = TagGroup::AsDict.groups_with_tags("Person")
  end

  def register_params
    params.require(:org_unit_register).permit(
      :org_name, :tax_nip, :country, :zipcode, :city, :street, :house_nr, :flat_nr, :comments,
      :org_unit_collab, :org_unit_email, :org_unit_phone, :org_unit_www,
      { org_unit_tags: [:id, { ids: [] } ] }, { person_tags: [:id, { ids: [] } ] },
      :first_employee, :person_title_id, :job_title_id, :first_name, :last_name, :unknown_name,
      :person_collab, :person_email, :person_phone, :person_www)
  end

  def update_params
    params.require(:org_unit).permit(:name, :collab, :tax_nip)
  end

end
