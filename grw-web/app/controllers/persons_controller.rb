class PersonsController < ClientController
  include PermControl
  before_action :load_dictionaries, except: %i(show)

  def show
    @person = Person.find(params[:id])
    @main_job = @person.main_person_job
    @visits = @person.activity_visits.to_a
  end

  def new
    @register = Person::Register.new(org_unit_id: params[:org_unit_id])
  end

  def create
    @register = Person::Register.new(register_params)
    if @register.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @person = Person::AsEdit.find(params[:id])
  end

  def update
    @person = Person::AsEdit.find(params[:id])
    if @person.update_attributes(update_params)
      flash[:success] = "Zmiany zapisane."
      rw_redirect_back
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def load_dictionaries
    @collab_list = OrgUnit::AsDict.collab_opt
    @job_titles = JobTitle::AsDict.list
    @person_titles = PersonTitle::AsDict.list
  end

  def register_params
    params.require(:person_register).permit(
      :org_unit_id, :person_title_id, :job_title_id, :first_name, :last_name, :unknown_name, :collab, :email, :phone, :www)
  end

  def update_params
    params.require(:person).permit(
      :person_title_id, :first_name, :last_name, :unknown_name, :collab)
  end

end
