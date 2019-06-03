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

class User::AsPassword < User
  include ExtendedModel

  validates :password, presence: true, confirmation: true #, password_strength: true

  has_secure_password validations: false

end
