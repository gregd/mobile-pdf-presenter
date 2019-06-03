class LocationAddressJob < ApplicationJob
  queue_as :default

  def perform(location_summary)
    return unless location_summary.should_geocode_address?

    srv = AddressGeocode::Service.new("google")
    srv.reverse(location_summary)
  end
end
