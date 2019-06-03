module WithPresenter
  extend ActiveSupport::Concern

  included do
    attr_accessor :view_user_role, :view_view_context

    def presenter
      @presenter ||= begin
        raise "Current user role not available" unless UserRole.current
        raise "Current user role not available" unless PresenterBase.view_context
        klass = "#{self.class.name}::AsPresenter".constantize
        ob = self.becomes(klass)
        ob.view_user_role = UserRole.current
        ob.view_view_context = PresenterBase.view_context
        ob
      end
    end

    def h
      @view_view_context
    end
  end

  class_methods do
  end

end
