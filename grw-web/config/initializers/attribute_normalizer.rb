AttributeNormalizer.configure do |config|

  config.normalizers[:pg_array] = lambda do |value, options|
    if value.is_a?(Array)
      value.map do |elem|
        if elem.present?
          options[:integers] ? elem.to_i : elem
        else
          nil
        end
      end.compact
    else
      value
    end
  end

  config.normalizers[:rw_phone] = lambda do |value, options|
    value = value.is_a?(String) ? value.gsub(/[^0-9]+/, '') : value
    value = value.is_a?(String) && value.empty? ? nil : value
    value = value.is_a?(String) && value.size == 9 && value[0..1] != "48" ? "48#{value}" : value
    value
  end

end
