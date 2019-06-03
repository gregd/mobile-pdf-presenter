class Admin::MobileDevicesController < AdminController
  before_action :require_selected_account

  def index
    @devices = MobileDevice.active.
      includes(:user).
      joins(:user).
      order("users.last_name, users.first_name")

    @apk_version = Service::AndroidApk.apk_version
    @repo_head_rev = repo&.head_rev
  end

  def show
    @device = MobileDevice.find(params[:id])
  end

  def edit
    @device = MobileDevice.find(params[:id])
  end

  def update
    @device = MobileDevice.find(params[:id])
    if @device.update_attributes(device_params)
      flash[:success] = "Saved"
      rw_redirect_back
    else
      render :edit
    end
  end

  def destroy
    @device = MobileDevice.find(params[:id])
    @device.deactivate
    @device.save!
    flash[:success] = "Device #{@device.unique_identifier} deactivated"
    rw_redirect_back
  end

  private

  def repo
    @repo ||= begin
      user = Repo::UserAdmin.new(current_admin.id)
      Repo::Git.new(Account.current.id, Repo::List.default_repo, user)
    end
  end

  def device_params
    params.require(:mobile_device).permit!
  end

end
