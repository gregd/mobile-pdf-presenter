class Person::Register < ActiveType::Object
  include AccountScoped

  attr_accessor :modifier_user_role

  attribute :account_id, :integer
  attribute :id, :integer

  attribute :org_unit_id, :integer
  attribute :person_title_id, :integer
  attribute :job_title_id, :integer
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :unknown_name, :boolean
  attribute :collab, :string
  attribute :email, :string
  attribute :phone, :string
  attribute :www, :string

  normalize_attributes :first_name, :last_name, :collab, :email, :www
  normalize_attributes :phone, with: :rw_phone

  belongs_to :org_unit

  validates :org_unit_id, presence: true
  validates :person_title_id, presence: true
  validates :job_title_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :unknown_name, inclusion: { in: [true, false] }
  validates :collab, presence: true, inclusion: { in: OrgUnit::COLLAB_VALUES }
  validates :email, email: true, allow_nil: true
  validates :phone, rw_phone: true

  before_save :sync_changes

  def sync_changes
    Person.transaction do
      person = Person::AsEdit.create!(
        person_title_id: person_title_id,
        collab: collab,
        first_name: first_name,
        last_name: last_name,
        unknown_name: unknown_name)

      PersonJob::AsEdit.create!(
        main_job: true,
        job_title_id: job_title_id,
        org_unit_id: org_unit_id,
        person_id: person.id,
        person_uuid: person.uuid)

      if email
        Contact::AsEdit.create!(
          contactable: person,
          category: "email",
          address: email)
      end

      if phone
        Contact::AsEdit.create!(
          contactable: person,
          category: "phone",
          address: phone)
      end

      if www
        Contact::AsEdit.create!(
          contactable: person,
          category: "www",
          address: www)
      end

      self.id = person.id
    end
  end

end