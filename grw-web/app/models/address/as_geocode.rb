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

class Address::AsGeocode < Address
  include ExtendedModel

  def geocode_params
    raw_address = "#{zipcode} #{city}, #{street} #{house_nr}"
    { raw:      raw_address,
      house_nr: house_nr,
      street:   street,
      city:     city,
      zipcode:  zipcode,
      voi:      nil }
  end

  def set_geocode(ag_id, loc_type, lat, lng)
    self.address_geocode_id = ag_id
    self.ll_accuracy = loc_type
    self.lat = lat
    self.lng = lng
  end

end
