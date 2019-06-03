class AddressJob < ApplicationJob
  queue_as :default

  def perform(address)
    srv = AddressGeocode::Service.new("google")
    address = address.becomes(Address::AsGeocode)
    srv.resolv(address)
  end

end
