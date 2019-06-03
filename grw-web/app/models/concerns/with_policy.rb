module WithPolicy
  extend ActiveSupport::Concern

  included do
    def policy
      @policy ||= begin
        raise "Current user role not available" unless UserRole.current
        klass = "#{self.class.name}Policy".constantize
        klass.new(self, UserRole.current)
      end
    end
  end

  class_methods do
  end

end