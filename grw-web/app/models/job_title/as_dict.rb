# == Schema Information
#
# Table name: job_titles
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

class JobTitle::AsDict < JobTitle
  include ExtendedModel

  def self.list
    order("position").
      map {|r| [r.name, r.id] }
  end

end
