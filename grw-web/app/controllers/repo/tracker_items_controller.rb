class Repo::TrackerItemsController < ClientController
  include PermControl

  def index
    @items = TrackerItem.active.order("repo_name, base_name")
  end

  def destroy
    @item = TrackerItem.active.find(params[:id])
    @item.deactivate!
    rw_redirect_back
  end

end
