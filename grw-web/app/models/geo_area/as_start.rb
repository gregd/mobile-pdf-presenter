# == Schema Information
#
# Table name: geo_areas
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  parent_id      :integer
#  path           :ltree
#  name           :string
#  geo_brick_id   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  max_depth      :integer
#  children_count :integer
#  node_name      :integer
#  node_order     :integer
#

class GeoArea::AsStart < GeoArea
  include ExtendedModel

  GEO_TWO   = 1
  GEO_THREE = 2

  def self.for_first_user(account_id)
    where(account_id: account_id, parent_id: nil).first
  end

  def self.templates
    [["Kraj, 16 obszarów", GEO_TWO],
     ["Kraj, 4 regiony, po 4 obszary", GEO_THREE]].freeze
  end

  def self.partition_for(id)
    case id
      when GEO_TWO   then GeoPartition::AsStart::VOI_ID
      when GEO_THREE then GeoPartition::AsStart::COUNTY_ID
      else
        raise "not implemented #{id}"
    end
  end

  def self.create_initial(account_id, template_id)
    case template_id
      when GEO_TWO   then create_initial_2_level(account_id, partition_for(template_id))
      when GEO_THREE then create_initial_3_level(account_id, partition_for(template_id))
      else raise "Unknown template #{template}"
    end
  end

  private

  def self.create_initial_2_level(account_id, partition_id)
    partition = GeoPartition.find(partition_id)

    country = new
    country.account_id = account_id
    country.name = "Polska"
    country.max_depth = 3
    country.save!

    partition.geo_bricks.each do |b|
      area = new
      area.account_id    = account_id
      area.parent        = country
      area.name          = b.name
      area.save!

      ab = new
      ab.account_id    = account_id
      ab.parent        = area
      ab.geo_brick_id  = b.id
      ab.name          = b.name
      ab.save!
    end
  end

  def self.create_initial_3_level(account_id, partition_id)
    partition = GeoPartition.find(partition_id)

    country = new
    country.account_id = account_id
    country.name = "Polska"
    country.max_depth = 4
    country.save!

    reg1 = new
    reg1.account_id = account_id
    reg1.parent = country
    reg1.name = "Pn-Wsch"
    reg1.save!

    reg2 = new
    reg2.account_id = account_id
    reg2.parent = country
    reg2.name = "Pn-Zach"
    reg2.save!

    reg3 = new
    reg3.account_id = account_id
    reg3.parent = country
    reg3.name = "Pd-Zach"
    reg3.save!

    reg4 = new
    reg4.account_id = account_id
    reg4.parent = country
    reg4.name = "Pd-Wsch"
    reg4.save!

    [[reg1, ["mazowieckie", "podlaskie", "warmińsko-mazurskie", "lubelskie"]],
     [reg2, ["pomorskie", "zachodniopomorskie", "kujawsko-pomorskie", "lubuskie"]],
     [reg3, ["wielkopolskie", "dolnośląskie", "opolskie", "łódzkie"]],
     [reg4, ["śląskie", "małopolskie", "świętokrzyskie", "podkarpackie"]]].each do |r|
      reg = r[0]
      r[1].each do |name|
        area = new
        area.account_id = account_id
        area.parent = reg
        area.name = name
        area.save!

        partition.geo_bricks.where("long_name ilike '#{name},%'").each do |b|
          ab = new
          ab.account_id    = account_id
          ab.parent        = area
          ab.geo_brick_id  = b.id
          ab.name          = b.name
          ab.save!
        end
      end
    end
  end

end
