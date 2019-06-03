class Account::Register < ActiveType::Object
  attribute :id, :integer
  attribute :account_plan_id, :integer
  attribute :app_role_set_id, :integer
  attribute :subdomain, :string
  attribute :company, :string
  attribute :emp_template_id, :integer
  attribute :geo_template_id, :integer
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :email, :string
  attribute :phone, :string
  attribute :password, :string
  attribute :password_digest, :string

  has_secure_password validations: false
  normalize_attributes :company, :subdomain, :email, :first_name, :last_name
  normalize_attributes :phone, with: :rw_phone

  validates :account_plan_id, presence: true
  validates :app_role_set_id, presence: true
  validates :subdomain, presence: true, length: { minimum: 3, maximum: 24 }
  validates :company, presence: true
  validates :emp_template_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true
  validates :phone, presence: true, rw_phone: true
  validates :password, presence: true, confirmation: true #, password_strength: true

  validate :unique_subdomain
  before_save :create_records

  def unique_subdomain
    if Account.pluck(:subdomain).include?(self.subdomain)
      errors.add(:subdomain, "Domena jest zajęta")
    end
  end

  def create_records
    Account.transaction do
      a = Account.new
      a.account_plan_id  = self.account_plan_id
      a.app_role_set_id  = self.app_role_set_id
      a.company          = self.company
      a.subdomain        = self.subdomain
      a.geo_partition_id = GeoArea::AsStart.partition_for(geo_template_id) if geo_template_id
      a.save!

      c = a.build_config
      c.account_id = a.id
      c.save!

      EmpPosition::AsStart.create_initial(a.id, emp_template_id)
      GeoArea::AsStart.create_initial(a.id, geo_template_id) if geo_template_id

      u = User::AsEdit.new
      u.account_id      = a.id
      u.billable        = true
      u.email           = self.email
      u.phone           = self.phone
      u.first_name      = self.first_name
      u.last_name       = self.last_name
      u.password_digest = self.password_digest
      u.save!

      r = UserRole::AsEdit.new
      r.user_position   = 2
      r.account_id      = a.id
      r.user_id         = u.id
      r.app_role_id     = AppRole::AsEdit.for_admin_user(a.app_role_set_id).id
      r.save!

      r = UserRole::AsEdit.new
      r.user_position   = 1
      r.account_id      = a.id
      r.user_id         = u.id
      r.app_role_id     = AppRole::AsEdit.for_first_user(a.app_role_set_id).id
      r.emp_position_id = EmpPosition::AsStart.for_first_user(a.id).id
      r.geo_area_id     = GeoArea::AsStart.for_first_user(a.id).id if geo_template_id
      r.save!

      JobTitle::AsStart.create_initial(a.id)
      PersonTitle::AsStart.create_initial(a.id)
      if a.app_role_set.has_clients?
        TagGroup::AsStart.create_initial(a.id)
      end

      self.id = a.id

      Repo::Git.create_empty(a.id)
    end
  end

end