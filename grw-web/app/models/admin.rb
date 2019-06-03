# == Schema Information
#
# Table name: admins
#
#  id              :integer          not null, primary key
#  email           :string
#  phone           :string
#  password_digest :string
#

class Admin < ApplicationRecord
  has_one :admin_web_option
  has_secure_password

  after_create :add_helper_models

  def add_helper_models
    create_admin_web_option
  end

end
