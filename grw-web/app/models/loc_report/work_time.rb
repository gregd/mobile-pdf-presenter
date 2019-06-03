class LocReport::WorkTime

  def self.compute(emps, day)
    emps.map do |emp|
      route = LocationRoute.for_ur_and_day(emp.user_role_id, day)
      if route.nil? || route.outdated?
        route = LocationRoute::AsBuilder.compute(emp.user_role, day)
      end

      { emp:    emp,
        day:    day,
        route:  route }
    end
  end

  def self.compute_range(emps, date_range)
    emps.map do |emp|
      row = { emp: emp }

      row[:cols] = date_range.to_range.map do |day|
        route = LocationRoute.for_ur_and_day(emp.user_role_id, day)
        if route.nil? || route.outdated?
          route = LocationRoute::AsBuilder.compute(emp.user_role, day)
        end

        { day: day, route: route }
      end

      row
    end
  end

end