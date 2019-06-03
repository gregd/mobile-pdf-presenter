module UserRolesHelper

  def urh_long_name(role)
    s = role.app_role.name
    s << " - #{role.emp_position.name}" if role.emp_position_id
    s
  end

end
