# == Schema Information
#
# Table name: geo_bricks
#
#  id               :integer          not null, primary key
#  geo_partition_id :integer
#  name             :string
#  long_name        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

class GeoBrick < ApplicationRecord
  belongs_to :geo_partition
  has_many :geo_zipcodes, dependent: :delete_all
  has_many :geo_areas

end
