# == Schema Information
#
# Table name: geo_zipcodes
#
#  id           :integer          not null, primary key
#  geo_brick_id :integer
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  deleted_at   :datetime
#

class GeoZipcode < ApplicationRecord
  belongs_to :geo_brick

end
