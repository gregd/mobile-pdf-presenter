class Admin::TrackerAppEventsController < AdminController

  def index
    @event_category = params[:event_category].present? ? params[:event_category] : nil
    @event_action = params[:event_action].present? ? params[:event_action] : nil

    @device = MobileDevice.find(params[:mobile_device_id])
    @events = TrackerAppEvent.
      where(mobile_device_id: @device.id).
      order("id DESC").
      page(params[:page]).
      per_page(30)
    @events = @events.where("category ILIKE ?", "#{@event_category}%") if @event_category
    @events = @events.where("action ILIKE ?", "#{@event_action}%") if @event_action
  end

end
