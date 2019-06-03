# == Schema Information
#
# Table name: addresses
#
#  id                 :integer          not null, primary key
#  account_id         :integer
#  uuid               :uuid
#  geo_brick_id       :integer
#  klass              :string
#  zipcode            :string
#  city               :string
#  street             :string
#  house_nr           :string
#  flat_nr            :string
#  comments           :string
#  searchable_addr    :string
#  address_geocode_id :integer
#  ll_accuracy        :string
#  lat                :float
#  lng                :float
#  loc_confirmed      :boolean          default(FALSE), not null
#  addr_confirmed     :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted_at         :datetime
#  lock_version       :integer          default(0)
#  country            :string
#

class Address < ApplicationRecord
  include AccountScoped
  include WithPresenter

  belongs_to :geo_brick, optional: true
  has_many :org_unit_addresses

  def has_location?
    !! lat
  end

  def main_org_unit
    @main_org_unit ||= begin
      a = org_unit_addresses.active.first
      a ? a.org_unit : nil
    end
  end

  def lat_lng
    @lat_lng ||= Geokit::LatLng.new(self.lat, self.lng)
  end

end
