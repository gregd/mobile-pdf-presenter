class Admin::MobileTimeChangesController < AdminController

  def index
    @device = MobileDevice.find(params[:mobile_device_id])
    @changes = MobileTimeChange.
      where(mobile_device_id: @device.id).
      order("id DESC").
      page(params[:page]).
      per_page(30)
  end

end
