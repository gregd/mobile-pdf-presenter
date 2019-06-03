class GeoAreasController < ClientController
  include PermControl
  before_action :load_dictionaries

  def index
    @areas = GeoArea::AsEdit.
      where("geo_brick_id IS NULL").
      order("path")
  end

  def show
    @area = GeoArea::AsEdit.find(params[:id])
  end

  def new
    @area = GeoArea::AsEdit.new

    if params[:parent_id].present?
      @area.parent_id = params[:parent_id]
    end
  end

  def create
    @area = GeoArea::AsEdit.new(area_params)
    if @area.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @area = GeoArea::AsEdit.find(params[:id])
    render :new
  end

  def update
    @area = GeoArea::AsEdit.find(params[:id])
    if @area.update_attributes(area_params)
      rw_redirect_back
    else
      render :new
    end
  end

  def destroy
    area = GeoArea::AsEdit.find(params[:id])
    area.destroy!
    flash[:success] = "Obszar #{area.name} usunięty."
    rw_redirect_back
  end

  private

  def load_dictionaries
    @parents = GeoArea::AsDict.for_users
  end

  def area_params
    params.require(:geo_area).permit!
  end

end
