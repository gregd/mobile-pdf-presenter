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

class Address::AsPresenter < Address
  include ExtendedModel

  def view_short
    s = "#{city}, #{street} #{house_nr}"
    s << "/#{flat_nr}" if flat_nr
    s.html_safe
  end

  def view_long
    s = "#{zipcode} #{city}, #{street} #{house_nr}"
    s << "/#{flat_nr}" if flat_nr
    s << " <span class='text-size-small'>#{comments}</span>" if comments
    s.html_safe
  end

end
