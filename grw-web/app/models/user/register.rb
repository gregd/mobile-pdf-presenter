class User::Register < ActiveType::Object
  include AccountScoped

  attribute :id, :integer
  attribute :account_id, :integer
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :email, :string
  attribute :phone, :string
  attribute :app_role_id, :integer
  attribute :emp_position_id, :integer
  attribute :geo_area_id, :integer
  attribute :send_invitation, :boolean

  normalize_attributes :email, :first_name, :last_name
  normalize_attributes :phone, with: :rw_phone

  validates :account_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true
  validates :phone, presence: true, rw_phone: true
  validates :app_role_id, presence: true
  validates :emp_position_id, presence: true

  before_save :create_records

  def create_records
    u = User::AsEdit.new
    u.account_id      = self.account_id
    u.first_name      = self.first_name
    u.last_name       = self.last_name
    u.email           = self.email
    u.phone           = self.phone
    u.save!

    r = UserRole::AsEdit.new
    r.account_id      = self.account_id
    r.user_id         = u.id
    r.app_role_id     = self.app_role_id
    r.emp_position_id = self.emp_position_id
    r.geo_area_id     = self.geo_area_id
    r.save!

    if send_invitation
      UserToken.send_invitation(u)
    end

    self.id = u.id
  end

  def self.can_add_new?
    User.active.count < Account.current.account_plan.max_users
  end

end