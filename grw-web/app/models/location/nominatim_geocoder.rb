module Location

  class NominatimGeocoder
    def initialize
    end

    def category
      "nominatim"
    end

    def day_limit
      # http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy
      10000
    end

    def geocode(house_nr, street, city, zipcode, voi)
      url = URI.parse('http://nominatim.openstreetmap.org/search')
      url.query = URI::encode_www_form(
        { 'country'         => 'pl',
          'accept-language' => 'pl',
          'limit'           => 10,
          'addressdetails'  => 1,
          'namedetails'     => 1,
          'email'           => 'gdaniluk@gmail.com',
          'format'          => 'json',
          'q'               => "#{city}, #{street} #{house_nr}",
          'postalcode'      => zipcode,
          'state'           => "województwo #{voi}"
        })

      response = Net::HTTP.get_response(url)
      arr = ActiveSupport::JSON.decode(response.body)

      filtered = arr.select do |j|
        a = j["address"]
        v = a["state"].gsub("województwo", "").strip
        ::Zipcode.fuzzy_match?(zipcode, a["postcode"]) || match_voi_city(voi, city, v, a["city"])
      end.sort_by {|j| name_rank(j) }.reverse

      selected = nil
      type = nil

      if filtered.size > 0
        selected = filtered[0]
        type = "ROOFTOP"
      elsif arr.size > 0
        selected = arr[0]
        type = "APPROXIMATE"
      end

      if selected
        j = selected
        { :ok => true,
          :quota => false,
          :type => type,
          :lat => j["lat"].to_f,
          :lng => j["lon"].to_f,
          :address => j["display_name"],
          :extra_type => osm_type(j),
          :response => response.body }
      else
        { :ok => false,
          :quota => false,
          :response => response.body }
      end
    end

    def reverse
      # TODO
    end

    private

    def osm_type(j)
      "#{j["osm_type"]}|#{j["class"]}|#{j["type"]}"
    end

    def match_voi_city(voi, city, voi2, city2)
      (/#{voi}/i =~ voi2) && (/#{city}/i =~ city2)
    end

    def name_rank(j)
      rank = 0

      %w(pharmacy hospital).each do |keyword|
        if j["address"].has_key?(keyword)
          rank += 1
        end
      end

      s = j["display_name"]
      %w(apteka apteczny szpital szpitalny szpitalna przychodnia medyczny medycznego pharm farma gabinet lekarz lekarska
          zielarsko zielarski mediq farmaceutyczne zdrowie zdrowo medica).each do |keyword|
        if s.match(/#{keyword}/i)
          rank += 1
        end
      end

      rank
    end

  end

end
