# == Schema Information
#
# Table name: app_roles
#
#  id              :integer          not null, primary key
#  app_role_set_id :integer
#  position        :integer
#  name            :string
#  user_admin_role :boolean          default(FALSE)
#  first_user_role :boolean          default(FALSE)
#  default_role    :boolean          default(FALSE)
#  cap_mobile_app  :boolean          default(FALSE)
#  cap_presenter   :boolean          default(FALSE)
#  cap_location    :boolean          default(FALSE)
#  cap_projects    :boolean          default(FALSE)
#  cap_crm         :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#

class AppRole < ApplicationRecord
  belongs_to :app_role_set
  has_many :app_permissions, :dependent => :delete_all
  has_many :user_roles

  default_scope -> { order("app_roles.position, app_roles.app_role_set_id") }
  scope :active, -> { where("app_roles.deleted_at IS NULL") }

end
