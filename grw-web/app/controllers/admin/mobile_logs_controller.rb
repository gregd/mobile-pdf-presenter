class Admin::MobileLogsController < AdminController

  def index
    @device = MobileDevice.find(params[:mobile_device_id])
    @logs = @device.logs.order("created_at DESC")
  end

  def show
    @log = MobileLog.find(params[:id])
    send_file(@log.asset.path,
              :filename => @log.asset.original_filename,
              :type => @log.asset.content_type,
              :disposition => "inline")
  end

end
