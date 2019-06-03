module Excelto
  module ActionController

    protected

    def excelto(options)
      @excelto_options = options
    end

    def compute_excelto_options
      @excelto_options || {}
    end

  end
end

class ActionController::Base
  include Excelto::ActionController
end
