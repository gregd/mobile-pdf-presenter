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

class Address::AsEdit < Address
  include ExtendedModel

  attr_accessor :modifier_user_role

  normalize_attributes :country, :zipcode, :city, :street, :house_nr, :flat_nr, :comments

  validates :klass, inclusion: %w(UserAddress OrgUnitAddress)
  validates :uuid, presence: true
  validates :country, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true
  validates :street, presence: true
  validate :validate_membership

  before_validation :set_defaults, :normalize_address
  after_save :add_jobs

  def set_defaults
    self.uuid = SecureRandom.uuid unless uuid
  end

  def deactivate
    self.deleted_at = Time.now
  end

  def validate_membership
    return unless modifier_user_role
    args = { zipcode: zipcode }
    # add eco sector
    modifier_user_role.validate_membership(args, errors)
  end

  def street_address_changed?
    country_changed? || zipcode_changed? || city_changed? || street_changed? || house_nr_changed? || flat_nr_changed?
  end

  def normalize_address
    if zipcode_changed? && Account.current.has_geo_structure?
      gp = Account.current.geo_partition
      brick = gp.brick_for_zipcode(zipcode)
      self.geo_brick_id = brick.id if brick
    end

    self.city = RwAddrNormalizer.capitalize_city(city)        if city_changed?
    self.street = RwAddrNormalizer.capitalize_street(street)  if street_changed?

    if street_address_changed?
      self.searchable_addr = normalized_addr
      self.loc_confirmed = false

      @should_geocode_addr = true
    else
      @should_geocode_addr = false
    end
  end

  def normalized_addr
    %i(country city street house_nr flat_nr).map do |col|
      val = send(col)
      val.present? ? RwStringExt.simplify(val) : nil
    end.compact.join(" ")
  end

  def add_jobs
    if @should_geocode_addr
      AddressJob.set(wait: 10.seconds).perform_later(self)
    end
  end

end
