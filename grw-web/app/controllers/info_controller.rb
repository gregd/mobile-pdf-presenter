class InfoController < ClientController
  skip_before_action :authorize_user, :load_user_role, :authorize_access
  layout 'only_logo'

  def index
  end

  def android
  end

end
