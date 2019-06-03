class DateRange

  attr_accessor :start_on, :end_on

  def initialize(start_on = nil, end_on = nil)
    @start_on = get_date_from(start_on)
    @end_on   = get_date_from(end_on)
    fix_order
  end

  # Sets start and end dates. Doesn't override previous value if a new one isn't valid.
  def set_start_end(start_value, end_value)
    @start_on = get_date_from(start_value)  || @start_on
    @end_on   = get_date_from(end_value)    || @end_on
    fix_order
  end

  def to_s
    "#{ start_on.to_date.to_s(:db) } - #{ end_on.to_date.to_s(:db) }"
  end

  def to_range
    start_on .. end_on
  end

  private

  def get_date_from(ob)
    if ob.is_a?(Date)
      ob
    elsif ob.is_a?(DateTime)
      ob.to_date
    elsif ob.present? && ob.is_a?(String)
      begin
        Date.parse(ob)
      rescue ArgumentError => ex
        nil
      end
    else
      nil
    end
  end

  def fix_order
    return if @start_on.nil? || @end_on.nil?
    if @start_on > @end_on
      @start_on, @end_on = @end_on, @start_on
    end
  end

end
