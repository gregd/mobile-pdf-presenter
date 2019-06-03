module PermControl
  extend ActiveSupport::Concern

  class_methods do
    def perm_control?
      true
    end
  end

end