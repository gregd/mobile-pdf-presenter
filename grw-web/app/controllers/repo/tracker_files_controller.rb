class Repo::TrackerFilesController < ClientController
  include PermControl

  def link
    @file = TrackerFile.find(params[:id])
    @items = TrackerItem.possible_for(@file)
  end

  def update
    @file = TrackerFile.find(params[:id])
    @file.update_attributes(tracker_file_params)
    app_update_flash(@file)
    rw_redirect_back
  end

  private

  def tracker_file_params
    params.require(:tracker_file).permit(:tracker_item_id)
  end

end
