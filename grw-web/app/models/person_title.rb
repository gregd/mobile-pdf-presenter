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

class PersonTitle < ApplicationRecord
  include AccountScoped
  has_many :persons

end
