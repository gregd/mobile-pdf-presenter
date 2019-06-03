class User::PasswordReset < ActiveType::Object
  attribute :category, :string
  attribute :email, :string
  attribute :token, :string
  attribute :pin, :string
  attribute :password, :string
  attribute :password_digest, :string

  has_secure_password validations: false

  validates :pin, presence: true
  validates :password, presence: true, confirmation: true #, password_strength: true

  def invitation?
    category == "invitation"
  end

  def valid_for_stage_one?
    category.present? && email.present? && token.present?
  end

end