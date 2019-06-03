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

class AppRole::AsEdit < AppRole
  include ExtendedModel
  attr_accessor :perms_from_role_id

  validates :app_role_set_id, presence: true
  validates :position, presence: true
  validates :name, presence: true, uniqueness: { scope: :app_role_set_id }

  before_validation :set_position
  after_create :init_permissions
  before_destroy :check_assignments

  def set_position
    if self.position.nil?
      self.position = (self.class.maximum(:position) || 0) + 1
    end
  end

  def check_assignments
    if user_roles.count > 0
      raise "There are user role objects linked to this role"
    end
  end

  def init_permissions
    if self.perms_from_role_id
      AppPermission::AsEdit.copy_perms self.perms_from_role_id, self.id
    else
      AppPermission::AsEdit.init_perms self.id
    end
  end

  def update_capabilities
    self.cap_mobile_app = ::AppPermission.has_access?("logins", "_mobile_app", self.id)
    self.cap_presenter  = ::AppPermission.has_access?("repo/browser", "_presenter", self.id)
    self.cap_location   = ::AppPermission.has_access?("loc/location_summaries", "_location", self.id)
  end

  def next_role
    self.class.where("app_role_set_id = ? AND position > ?", self.app_role_set_id, self.position).
      order("position").limit(1).first
  end

  def self.update_capabilities
    all.each {|ar| ar.update_capabilities; ar.save! }
  end

  def self.for_admin_user(app_role_set_id)
    where("user_admin_role IS TRUE AND app_role_set_id = ?", app_role_set_id).first
  end

  def self.for_first_user(app_role_set_id)
    where("first_user_role IS TRUE AND app_role_set_id = ?", app_role_set_id).first
  end

end
