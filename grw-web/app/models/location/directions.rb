# https://developers.google.com/maps/documentation/directions/intro#Routes
# https://developers.google.com/maps/documentation/utilities/polylineutility
# http://stackoverflow.com/questions/32467212/google-maps-marker-label-with-multiple-characters
# departure_time (It cannot be in the past.)
# duration_in_traffic (cannot have waypoints)
# alternatives

module Location

  class Directions
    def self.ll_to_route(point_start, point_end, waypoints)
      params = "origin=#{point_start.lat},#{point_start.lng}&destination=#{point_end.lat},#{point_end.lng}"
      if waypoints.size > 0
        params = "#{params}&waypoints=#{waypoints.map {|w| "#{w.lat},#{w.lng}"}.join('|')}"
      end
      response = Net::HTTP.get_response(
        URI.parse("https://maps.googleapis.com/maps/api/directions/json?units=metric&language=pl&#{params}&key=#{Rails.application.secrets.google_server_key}"))
      json = ActiveSupport::JSON.decode(response.body)

      if json["status"] == "OK"
        route = json["routes"][0]

        legs = route["legs"].map do |leg|
          { meters: leg["distance"]["value"],
            seconds: leg["duration"]["value"] }
        end

        { :ok             => true,
          :quota          => false,
          :legs           => legs,
          :total_meters   => legs.map {|l| l[:meters] }.sum,
          :total_seconds  => legs.map {|l| l[:seconds] }.sum,
          :response       => response.body }

      else
        { :ok       => false,
          :quota    => (json["status"] == "OVER_QUERY_LIMIT"),
          :response => response.body }
      end
    end
  end

end

