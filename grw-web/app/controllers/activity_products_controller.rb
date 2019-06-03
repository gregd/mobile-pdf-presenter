class ActivityProductsController < ClientController
  include PermControl
  before_action :load_dictionaries

  def index
    @products = ActivityProduct::AsEdit.active.order("activity_product_group_id, position")
  end

  def new
    @product = ActivityProduct::AsEdit.new
    @product.activity_product_group_id = params[:activity_product_group_id]
  end

  def create
    @product = ActivityProduct::AsEdit.new(product_params)
    if @product.save
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @product = ActivityProduct::AsEdit.find(params[:id])
    render :new
  end

  def update
    @product = ActivityProduct::AsEdit.find(params[:id])
    if @product.update_attributes(product_params)
      rw_redirect_back
    else
      render :new
    end
  end

  def destroy

  end

  private

  def load_dictionaries
    @groups = ActivityProductGroup::AsDict.for_products
  end

  def product_params
    params.require(:activity_product).permit(
      :name, :abbr, :position, :activity_product_group_id)
  end

end
