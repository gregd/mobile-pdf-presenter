class MassPrint < ActiveType::Object
  attribute :text,                :string
  attribute :person_search_id,    :integer
  attribute :org_unit_search_id,  :integer

  belongs_to :person_search, optional: true
  belongs_to :org_unit_search, optional: true

  validates :text, presence: true, if: :any_text?

  def any_text?
    person_search_id.nil? && org_unit_search_id.nil?
  end

  def receivers(limit = nil)
    if person_search_id
      person_search.per_page = nil
      persons = person_search.execute
      persons = persons[0 .. (limit - 1)] if limit
      persons.map {|p| [p, p.main_org_unit, p.main_org_unit.main_address ] }

    elsif org_unit_search_id
      org_unit_search.per_page = nil
      units = org_unit_search.execute
      units = units[0 .. (limit - 1)] if limit
      units.map {|u| [u.persons.first, u, u.main_address ] }

    else
      []
    end
  end

end