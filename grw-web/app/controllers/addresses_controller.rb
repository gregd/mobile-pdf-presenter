class AddressesController < ClientController
  include PermControl

  def new

  end

  def create

  end

  def edit
    @address = Address::AsEdit.find(params[:id])
  end

  def update
    @address = Address::AsEdit.find(params[:id])
    @address.modifier_user_role = current_user_role
    @address.attributes = address_params
    if @address.save
      rw_redirect_back
    else
      render :edit
    end
  end

  def destroy

  end

  private

  def address_params
    params.require(:address).permit(
      :country, :zipcode, :city, :street, :house_nr, :flat_nr, :comments)
  end

end
