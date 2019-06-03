module PersonsHelper

  def rw_person_title(p)
    "#{p.person_title.name}"
  end

  def rw_person_full_name(p)
    "#{p.last_name} #{p.first_name}"
  end

end
