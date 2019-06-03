class Planned::ActivityVisitsController < ClientController
  include PermControl

  def new
    @visit = ActivityVisit::PlanSingle.new
    @visit.user_role_id     = current_user_role.id
    @visit.activity_on      = default_plan_date
    @visit.org_unit_id      = params[:org_unit_id]
    @visit.person_id        = params[:person_id]
    if params[:address_id]
      @visit.address_id = params[:address_id]
    else
      @visit.address_id = @visit.org_unit.main_address.id
    end
  end

  def create
    @visit = ActivityVisit::PlanSingle.new(planned_visit_params)
    @visit.creator_role_id  = current_user_role.id
    @visit.user_role_id     = current_user_role.id

    if @visit.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @visit = ActivityVisit::PlanSingle.find(params[:id])
  end

  def update
    @visit = ActivityVisit::PlanSingle.find(params[:id])
    @visit.attributes       = planned_visit_params
    @visit.creator_role_id  = current_user_role.id
    @visit.user_role_id     = current_user_role.id

    if @visit.save
      rw_redirect_back
    else
      render :edit
    end
  end

  def convert_to_reported
    @visit = ActivityVisit::PlanSingle.find(params[:id])
    if @visit.policy.can_convert_to_reported?
      @visit.convert_to_reported!
      redirect_to edit_reported_activity_visit_path(@visit.id, redirect_back_params)
    else
      app_update_flash(@visit.policy)
      rw_redirect_back
    end
  end

  def destroy
    @visit = ActivityVisit::PlanSingle.find(params[:id])
    if @visit.policy.can_destroy?
      @visit.destroy!
    end
    app_update_flash(@visit.policy) { "Wizyta usunięta." }
    rw_redirect_back
  end

  private

  def default_plan_date
    if params[:date]
      Time.zone.parse(params[:date]).to_date
    elsif session[:default_plan_date]
      Time.zone.parse(session[:default_plan_date]).to_date
    else
      Date.today + 7
    end
  end

  def planned_visit_params
    params.require(:activity_visit_plan_single).
      permit(:org_unit_id, :address_id, :person_id, :comments, :activity_on, :has_time, :begin_at, :end_at)
  end

end
