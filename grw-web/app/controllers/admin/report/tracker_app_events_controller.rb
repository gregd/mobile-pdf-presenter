class Admin::Report::TrackerAppEventsController < AdminController

  def index
    @filter = TrackerAppEvent::AdminFilter.new(filter_params)
    @filter.page = params[:page]
    @filter.per_page = 30
    @events = @filter.events
  end

  private

  def filter_params
    params.fetch(:tracker_app_event_admin_filter, {}).permit!
  end

end
