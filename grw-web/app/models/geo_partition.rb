# == Schema Information
#
# Table name: geo_partitions
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class GeoPartition < ApplicationRecord
  has_many :geo_bricks, dependent: :destroy
  has_many :geo_zipcodes, through: :geo_bricks
  has_many :accounts

  def brick_for_zipcode(zipcode)
    gz = geo_zipcodes.where("zipcode = ?", zipcode).first
    gz ? gz.geo_brick : nil
  end

end
