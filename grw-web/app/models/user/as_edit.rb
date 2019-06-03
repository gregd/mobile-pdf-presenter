# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  first_name      :string
#  last_name       :string
#  email           :string
#  phone           :string
#  password_digest :string
#  billable        :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#

class User::AsEdit < User
  include ExtendedModel
  has_many :all_user_roles, class_name: "UserRole::AsEdit", foreign_key: "user_id", autosave: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true, uniqueness: { scope: :account_id }
  validates :phone, presence: true
  validates :billable, inclusion: [true, false]

  after_initialize :set_default_values
  before_create :set_required_values
  after_create :add_helper_models

  has_secure_password validations: false

  def set_default_values
    self.billable = true if self.billable.nil?
  end

  def set_required_values
    if self.password_digest.nil?
      p = SecureRandom.hex(32)
      self.password = p
      self.password_confirmation = p
    end
  end

  def add_helper_models
    # User model is also created during account creation, so subdomain is not active.
    # Therefore have to set account_id manually.
    w = build_user_web_option
    w.account_id = self.account_id
    w.save!

    m = build_user_mobile_option
    m.account_id = self.account_id
    m.save!
  end

  def deactivate
    self.all_user_roles.each do |ur|
      ur.deactivate
    end

    self.deleted_at = Time.now
  end

end
