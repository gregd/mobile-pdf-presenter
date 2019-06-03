module Location

  class GoogleGeocoder
    def initialize
    end

    def category
      "google_geocode"
    end

    def day_limit
      2490
    end

    def geocode(house_nr, street, city, zipcode, voi)
      url = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?key=#{Rails.application.secrets.google_server_key}")
      a = "#{city}, #{street} #{house_nr}"
      c = "country:PL"
      c << "|administrative_area_level_1:#{voi}"  if voi
      # c << "|postal_code:#{zipcode}"              if zipcode   # zipcode fools google geocoder!
      url.query = URI::encode_www_form(
        { 'region'      => 'pl',
          'language'    => 'pl',
          'address'     => a,
          'components'  => c
        })

      response = Net::HTTP.get_response(url)
      json = ActiveSupport::JSON.decode(response.body)
      if json["status"] == "OK"
        j = json["results"][0]
        { :ok         => true,
          :quota      => false,
          :type       => j["geometry"]["location_type"],
          :lat        => j["geometry"]["location"]["lat"].to_f,
          :lng        => j["geometry"]["location"]["lng"].to_f,
          :address    => j["formatted_address"],
          :extra_type => j["types"].join("|"),
          :response   => response.body }
      else
        { :ok => false,
          :quota => (json["status"] == "OVER_QUERY_LIMIT"),
          :response => response.body }
      end
    end

    def reverse(lat, lng)
      response = Net::HTTP.get_response(URI.parse("https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&language=pl&key=#{Rails.application.secrets.google_server_key}"))
      json = ActiveSupport::JSON.decode(response.body)

      if json["status"] == "OK"
        address = json["results"][0]["formatted_address"]
        address = address.gsub(", Polska", "")
        address = address.gsub(/\d{2}-\d{3}/, "")

        { :ok => true,
          :address => address,
          :response => response.body }

      else
        { :ok => false,
          :zero => json["status"] == "ZERO_RESULTS",
          :quota => (json["status"] == "OVER_QUERY_LIMIT"),
          :response => response.body }
      end

    rescue Exception => e
      { :ok => false,
        :response => e.message }
    end
  end

end
