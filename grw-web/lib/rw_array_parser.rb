class RwArrayParser
  extend PgArrayParser

  def self.as_strings(arr)
    parse_pg_array(arr)
  end

  def self.as_ints(arr)
    parse_pg_array(arr).map {|i| i.to_i }
  end

end