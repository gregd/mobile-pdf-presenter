class OrgUnit::Register < ActiveType::Object
  include AccountScoped

  attr_accessor :modifier_user_role

  attribute :account_id, :integer
  attribute :id, :integer

  attribute :org_name, :string
  attribute :tax_nip, :string
  attribute :country, :string
  attribute :zipcode, :string
  attribute :city, :string
  attribute :street, :string
  attribute :house_nr, :string
  attribute :flat_nr, :string
  attribute :comments, :string
  attribute :org_unit_collab, :string
  attribute :org_unit_email, :string
  attribute :org_unit_phone, :string
  attribute :org_unit_www, :string
  attribute :org_unit_tags, default: proc { Hash.new }

  attribute :first_employee, :boolean, default: proc { false }
  attribute :unknown_name, :boolean, default: proc { false }
  attribute :person_title_id, :integer
  attribute :job_title_id, :integer
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :person_collab, :string
  attribute :person_email, :string
  attribute :person_phone, :string
  attribute :person_www, :string
  attribute :person_tags, default: proc { Hash.new }

  normalize_attributes :org_name, :tax_nip, :country, :zipcode, :city, :street, :house_nr, :flat_nr, :comments,
                       :org_unit_collab, :org_unit_email, :org_unit_www,
                       :first_name, :last_name, :person_collab, :person_email, :person_www
  normalize_attributes :org_unit_phone, :person_phone, with: :rw_phone

  validates :org_name, presence: true
  validates :zipcode, presence: true
  validates :country, presence: true
  validates :city, presence: true
  validates :street, presence: true
  validates :org_unit_collab, presence: true, inclusion: { in: OrgUnit::COLLAB_VALUES }
  validates :org_unit_phone, rw_phone: true
  validate :validate_membership

  validates :first_employee, inclusion: { in: [true, false] }
  validates :unknown_name, inclusion: { in: [true, false] }
  validates :person_title_id, presence: true, if: :first_employee
  validates :job_title_id, presence: true, if: :first_employee
  validates :first_name, presence: true, if: :first_employee
  validates :last_name, presence: true, if: :first_employee
  validates :person_collab, presence: true, inclusion: { in: OrgUnit::COLLAB_VALUES }, if: :first_employee
  validates :person_phone, rw_phone: true

  after_initialize :set_defaults
  before_save :sync_changes

  def set_defaults
    if new_record? && org_unit_collab.nil?
      # TODO znajdz rekordy dodane przez aktualnego użytkownika
      if last_ou = OrgUnit.active.order("created_at DESC").first
        self.org_unit_collab = last_ou.collab
      end
      if last_person = Person.active.order("created_at DESC").first
        if last_person.unknown_name
          self.person_title_id  = last_person.person_title_id
          self.person_collab    = last_person.collab
          self.unknown_name     = last_person.unknown_name
          self.first_name       = last_person.first_name
          self.last_name        = last_person.last_name
          self.job_title_id     = last_person.main_person_job&.job_title_id
        end
      end
    end
  end

  def validate_membership
    args = { zipcode: zipcode }
    # add eco sector
    modifier_user_role.validate_membership(args, errors)
  end

  def sync_changes
    OrgUnit.transaction do
      ou = OrgUnit::AsEdit.create!(
        name: org_name,
        collab: org_unit_collab,
        tax_nip: tax_nip)

      addr = Address::AsEdit.create!(
        klass: "OrgUnitAddress",
        zipcode: zipcode,
        country: country,
        city: city,
        street: street,
        house_nr: house_nr,
        flat_nr: flat_nr,
        comments: comments)

      OrgUnitAddress::AsEdit.create!(
        org_unit_id: ou.id,
        address_id: addr.id,
        category: OrgUnitAddress::ADDR_MAIN)

      org_unit_tags.each_pair do |tag_group_id, tags_ids|
        tags_ids.each do |tag_id|
          Tagging::AsEdit.create!(
            taggable: ou,
            user_role_id: modifier_user_role.id,
            tag_id: tag_id)
        end
      end

      if org_unit_email
        Contact::AsEdit.create!(
          contactable: ou,
          category: "email",
          address: org_unit_email)
      end

      if org_unit_phone
        Contact::AsEdit.create!(
          contactable: ou,
          category: "phone",
          address: org_unit_phone)
      end

      if org_unit_www
        Contact::AsEdit.create!(
          contactable: ou,
          category: "www",
          address: org_unit_www)
      end

      if first_employee
        person = Person::AsEdit.create!(
          person_title_id: person_title_id,
          first_name: first_name,
          last_name: last_name,
          collab: person_collab,
          unknown_name: unknown_name)

        PersonJob::AsEdit.create!(
          main_job: true,
          job_title_id: job_title_id,
          org_unit_id: ou.id,
          person_id: person.id,
          person_uuid: person.uuid)

        person_tags.each_pair do |tag_group_id, tags_ids|
          tags_ids.each do |tag_id|
            Tagging::AsEdit.create!(
              taggable: person,
              user_role_id: modifier_user_role.id,
              tag_id: tag_id)
          end
        end

        if person_email
          Contact::AsEdit.create!(
            contactable: person,
            category: "email",
            address: person_email)
        end

        if person_phone
          Contact::AsEdit.create!(
            contactable: person,
            category: "phone",
            address: person_phone)
        end

        if person_www
          Contact::AsEdit.create!(
            contactable: person,
            category: "www",
            address: person_www)
        end
      end

      self.id = ou.id
    end
  end

  def org_unit_tags=(h)
    super(cast_tags_ids(h))
  end

  def person_tags=(h)
    super(cast_tags_ids(h))
  end

  private

  # @param [Hash] h example {"1"=>{"ids"=>["8"]}, "2"=>{"ids"=>["10", "11"]}}
  # @return [Hash] casted hash of ids
  def cast_tags_ids(h)
    if h.nil?
      nil
    else
      casted = {}
      h.each_pair do |k, v|
        casted[k.to_i] = v["ids"].map {|i| i.present? ? i.to_i : nil }.compact
      end
      casted
    end
  end

end
