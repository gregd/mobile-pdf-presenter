class ActivityVisitsController < ClientController
  include PermControl

  def route
    visit = ActivityVisit.find(params[:id])
    case visit.activity_stage
      when ActivityVisit::STAGE_PLANNED
        redirect_to edit_planned_activity_visit_path(visit, redirect_back_params)

      when ActivityVisit::STAGE_REPORTED
        redirect_to edit_reported_activity_visit_path(visit, redirect_back_params)

    end
  end

end
