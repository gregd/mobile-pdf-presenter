# == Schema Information
#
# Table name: person_titles
#
#  id         :integer          not null, primary key
#  account_id :integer
#  position   :integer
#  name       :string
#  abbr       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class PersonTitle::AsDict < PersonTitle
  include ExtendedModel

  def self.list
    order("position").
      map {|r| [r.name, r.id] }
  end

end
