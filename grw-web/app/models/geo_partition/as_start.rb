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

class GeoPartition::AsStart < GeoPartition
  include ExtendedModel

  VOI_ID = 1
  COUNTY_ID = 2

  def self.build_partitions(sio)
    if where(id: VOI_ID).count == 0
      build_voi(sio)
    end
    if where(id: COUNTY_ID).count == 0
      build_county(sio)
    end
  end

  def self.build_voi(sio)
    transaction do
      sio.puts "create voi geo partition"
      gp = create!(id: VOI_ID, name: "Województwa")
      voi_2_gb = {}

      # tylko 16 cegiełek, czyli struktura dla bardzo małych firm i do testów
      CityStreet::VOI_NAMES.each do |voi|
        gb = GeoBrick.create!(
          geo_partition_id: gp.id,
          name: voi,
          long_name: voi)
        voi_2_gb[voi] = gb.id
      end
      sio.puts "Bricks created"

      zipcodes = CityStreet.select_sql(<<-SQL)
        select zipcode
        from city_streets
        group by zipcode
        order by zipcode
      SQL

      count = 0
      zipcodes.each do |r|
        zipcode = r["zipcode"]

        voi = CityStreet.voi_by_zip(zipcode)
        raise "No voi for #{zipcode}" unless voi
        raise "No brick for #{voi}" unless voi_2_gb.has_key?(voi)
        bid = voi_2_gb[voi]

        GeoZipcode.create!(
          geo_brick_id: bid,
          zipcode: zipcode)

        count += 1
        sio.puts count if count % 1000 == 0
      end

      sio.puts "created geo zipcodes #{count}"
    end
  end

  def self.build_county(sio)
    transaction do
      sio.puts "create county geo partition"
      gp = create!(id: COUNTY_ID, name: "Powiaty")
      voi_2_gb = {}

      vc = CityStreet.select_sql <<-SQL
        select
          voi, county
        from
          city_streets
        group by
          voi, county
        order by
          voi, county
      SQL

      vc.each do |r|
        v = r["voi"]
        c = r["county"]
        l = "#{v}, #{c}"
        gb = GeoBrick.create!(
          geo_partition_id: gp.id,
          name: c,
          long_name: l)
        voi_2_gb[l] = gb.id
      end
      sio.puts "Bricks created"

      zipcodes = CityStreet.select_sql(<<-SQL)
        select zipcode
        from city_streets
        group by zipcode
        order by zipcode
      SQL

      count = 0
      zipcodes.each do |r|
        zipcode = r["zipcode"]

        voi, county = CityStreet.voi_county_by_zip(zipcode)
        raise "No voi for #{zipcode}" unless voi
        l = "#{voi}, #{county}"
        raise "No brick for #{voi}" unless voi_2_gb.has_key?(l)
        bid = voi_2_gb[l]

        GeoZipcode.create!(
          geo_brick_id: bid,
          zipcode: zipcode)

        count += 1
        sio.puts count if count % 1000 == 0
      end

      sio.puts "created geo zipcodes #{count}"
    end
  end

end
