module Location

  class GeoportalGeocoder
    include HTTParty
    base_uri 'http://mapy.geoportal.gov.pl'

    def initialize
    end

    def category
      "geoportal"
    end

    def day_limit
      10000
    end

    def geocode(house_nr, street, city, zipcode, voi)
      address = "#{city}, #{street} #{house_nr}"
      tid = voi.present? ? VOI_TO_TERYT_ID[voi] : nil
      puts "VOI: #{voi} TID: #{tid}"
      xml = <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <xls:XLS version="1.2"
            xmlns:xls="http://www.opengis.net/xls"
            xmlns:gugik_ols="http://www.geoportal.gov.pl/schema/ols"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <xls:RequestHeader/>
          <xls:Request methodName="GeocodeRequest" version="1.0.0" requestID="xyz">
            <gugik_ols:GeocodeRequest>
              <gugik_ols:AddressPoint countryCode="PL">
                <gugik_ols:freeFormAddress #{tid ? "idTERYT=\"#{tid}\"" : ''}>#{ address.encode(xml: :text) }</gugik_ols:freeFormAddress>
              </gugik_ols:AddressPoint>
            </gugik_ols:GeocodeRequest>
            </xls:Request>
          </xls:XLS>
      XML

      r = self.class.post('/openLSgp/geocode', {
        :body => xml,
        :headers => { 'Content-Type' => 'text/xml' } })
      #puts xml
      #puts r.body

      if r.ok?
        doc = Nokogiri::XML(r.body)
        doc.remove_namespaces!
        list = doc.xpath("//GeocodeResponseList")
        if list.first
          count = list.first["numberOfGeocodedAddresses"].to_i
          if count > 0
            addr = doc.xpath("//GeocodedAddress").first

            p = addr.xpath("//pos").first.text.strip
            lat, lng = p.split.reverse.map {|s| s.to_f }

            type = addr.xpath("//GeocodeMatchCode").first["accuracy"].to_f > 0.95 ? "ROOFTOP" : "APPROXIMATE"

            full_addr = []
            full_addr << addr.xpath("//AdministrativeUnit[@hierarchyLevel='wojewodztwo']").first.text
            full_addr << addr.xpath("//AdministrativeUnit[@hierarchyLevel='powiat']").first.text
            full_addr << addr.xpath("//AdministrativeUnit[@hierarchyLevel='gmina']").first.text
            full_addr << addr.xpath("//Place[@type='Municipality']").first.text
            full_addr << addr.xpath("//StreetAddress").first.text.strip

            return {
              ok:       true,
              quota:    false,
              type:     type,
              lat:      lat,
              lng:      lng,
              address:  full_addr.join("|"),
              response: r.body }
          end
        end
      end

      { ok:       false,
        quota:    false,
        response: r.body }
    end

    def reverse
      # TODO
    end

    private

    VOI_TO_TERYT_ID = {
      "dolnośląskie"        => "02",
      "kujawsko-pomorskie"  => "04",
      "łódzkie"             => "10",
      "lubelskie"           => "06",
      "lubuskie"            => "08",
      "małopolskie"         => "12",
      "mazowieckie"         => "14",
      "opolskie"            => "16",
      "podkarpackie"        => "18",
      "podlaskie"           => "20",
      "pomorskie"           => "22",
      "śląskie"             => "24",
      "świętokrzyskie"      => "26",
      "warmińsko-mazurskie" => "28",
      "wielkopolskie"       => "30",
      "zachodniopomorskie"  => "32" }.freeze
  end

end

