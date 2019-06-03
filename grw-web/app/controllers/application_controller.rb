class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  use_growlyflash
  before_action :presenters_prepare

  def no_subdomain
    render layout: false
  end

  def no_account
    @subdomain = params[:subdomain]
    render layout: false
  end

  private

  def app_update_flash(model)
    if model.errors.empty?
      if block_given?
        flash[:success] = yield
      end
    else
      flash[:error] = model.errors.full_messages.join("<br/>".html_safe)
    end
  end

  def presenters_prepare
    PresenterBase.set_view_context(view_context)
  end

  def self.perm_control?
    false
  end

end
