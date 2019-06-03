module RwValidations

  class ZipcodeValidator < ActiveModel::EachValidator
    def validate_each(record, attr_name, value)
      return if value.blank?
      unless valid_zipcode?(value)
        record.errors.add(attr_name, "jest niepoprawne")
      end
    end

    def valid_zipcode?(value)
      value.match(/^\d{2}-\d{3}$/)
    end
  end

  class NipValidator < ActiveModel::EachValidator
    def validate_each(record, attr_name, value)
      return if value.blank?
      unless valid_nip?(value)
        record.errors.add(attr_name, "jest niepoprawne")
      end
    end

    def valid_nip?(value)
      return false unless value.match(/^\d{10}$/)
      weights = [6,5,7,2,3,4,5,6,7]
      digits = value.split('').map { |n| n.to_i }
      digits[-1] == (digits[0..-2].sum { |n| n * weights.shift } % 11)
    end
  end

  class EmailValidator < ActiveModel::EachValidator
    def validate_each(record, attr_name, value)
      return if value.blank?
      unless valid_email?(value)
        record.errors.add(attr_name, "jest niepoprawne")
      end
    end

    def valid_email?(value)
      value.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
    end
  end

  class RwPhoneValidator < ActiveModel::EachValidator
    def validate_each(record, attr_name, value)
      return if value.blank?
      unless valid_mobile_number?(value)
        record.errors.add(attr_name, "jest niepoprawne")
      end
    end

    def valid_mobile_number?(value)
      value.match(/^48\d{9}$/)
    end
  end

end

ActiveRecord::Base.send(:include, RwValidations)
