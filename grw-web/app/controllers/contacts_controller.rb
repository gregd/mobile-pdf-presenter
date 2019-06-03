class ContactsController < ClientController
  include PermControl
  before_action :load_dictionaries

  def new
    @contact = Contact::AsEdit.new(
      contactable_type: params[:contactable_type],
      contactable_id: params[:contactable_id])
  end

  def create
    @contact = Contact::AsEdit.new(contact_params)
    if @contact.save
      flash[:success] = "Nowy kontakt dodany."
      rw_redirect_back
    else
      render :new
    end
  end

  def edit
    @contact = Contact::AsEdit.find(params[:id])
    render :new
  end

  def update
    @contact = Contact::AsEdit.find(params[:id])
    if @contact.update_attributes(contact_params)
      flash[:success] = "Kontakt uaktualniony."
      rw_redirect_back
    else
      render :new
    end
  end

  def destroy

  end

  private

  def load_dictionaries
    @categories = Contact::AsEdit.categories_opt
  end

  def contact_params
    params.required(:contact).permit(
      :contactable_type, :contactable_id, :category, :address, :comments)
  end

end
