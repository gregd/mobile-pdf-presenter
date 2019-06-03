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

class User::AsLogin < User
  include ExtendedModel
  has_secure_password validations: false

  def default_user_role
    user_roles.order("user_roles.user_position").first
  end

  def self.find_active(user_id)
    active.where("id = ?", user_id).first
  end

  def self.authenticate(email, password_to_check)
    false
  end

end
