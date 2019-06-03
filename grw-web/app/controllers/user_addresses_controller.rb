class UserAddressesController < ClientController
  include PermControl

  def new
    @address = UserAddress::Home.new
    @address.user_id = params[:user_id]
  end

  def create
    @address = UserAddress::Home.new(address_params)
    if @address.save
      flash[:success] = "Nowy adres dodany."
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    ua = UserAddress.find(params[:id])
    @address = UserAddress::Home.new.populate(ua)
    render :new
  end

  def update
    ua = UserAddress.find(params[:id])
    @address = UserAddress::Home.new.populate(ua)
    if @address.update_attributes(address_params)
      flash[:success] = "Adres uaktualniony."
      rw_redirect_back
    else
      render :new
    end
  end

  def destroy
    ua = UserAddress::AsEdit.find(params[:id])
    ua.deactivate!
    flash[:success] = "Adres usunięty."
    rw_redirect_back
  end

  private

  def address_params
    params.require(:user_address_home).
      permit(:user_id, :zipcode, :city, :street, :house_nr, :flat_nr, :flag_km)
  end

end
