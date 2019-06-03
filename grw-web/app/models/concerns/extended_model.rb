module ExtendedModel
  extend ActiveSupport::Concern

  # included do
  # end

  class_methods do

    def model_name
      superclass.model_name
    end

    def sti_name
      superclass.sti_name
    end

    private

    # def find_sti_class(type_name)
    #   sti_class = super(type_name)
    #   if self <= sti_class
    #     self
    #   else
    #     sti_class
    #   end
    # end

  end

end