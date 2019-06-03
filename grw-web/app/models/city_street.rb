# == Schema Information
#
# Table name: city_streets
#
#  id          :integer          not null, primary key
#  zipcode     :string
#  city        :string
#  city_long   :string
#  street      :string
#  street_long :string
#  numbers     :string
#  community   :string
#  county      :string
#  voi         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CityStreet < ApplicationRecord
  has_many :geo_zipcodes, foreign_key: "zipcode"

  attr_accessor :match_level

  def street_numbers
    @street_numbers ||= CityStreet::Street.new(numbers)
  end

  def self.voi_by_zip(code)
    res = select_sql(<<~SQL, code)
      select voi
      from city_streets
      where zipcode = ?
      group by voi
      order by count(*) desc
      limit 1
    SQL
    res.empty? ? nil : res[0]["voi"]
  end

  def self.voi_county_by_zip(code)
    res = select_sql(<<~SQL, code)
      select voi, county
      from city_streets
      where zipcode = ?
      group by voi, county
      order by count(*) desc
      limit 1
    SQL
    res.empty? ? [nil, nil] : [res[0]["voi"], res[0]["county"]]
  end

  VOI_NAMES = [
    "dolnośląskie",
    "kujawsko-pomorskie",
    "lubelskie",
    "lubuskie",
    "łódzkie",
    "mazowieckie",
    "małopolskie",
    "opolskie",
    "podkarpackie",
    "podlaskie",
    "pomorskie",
    "śląskie",
    "świętokrzyskie",
    "warmińsko-mazurskie",
    "wielkopolskie",
    "zachodniopomorskie"].freeze
end
