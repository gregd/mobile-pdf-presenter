# == Schema Information
#
# Table name: user_roles
#
#  id                    :integer          not null, primary key
#  account_id            :integer
#  user_id               :integer
#  app_role_id           :integer
#  emp_position_id       :integer
#  geo_area_id           :integer
#  eco_sector_id         :integer
#  user_position         :integer
#  emp_position_position :integer
#  geo_area_position     :integer
#  eco_sector_position   :integer
#  name                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  deleted_at            :datetime
#

class UserRole::AsEdit < UserRole
  include ExtendedModel
  validates :user_id, presence: true
  validates :app_role_id, presence: true

  before_validation :update_defaults
  before_save :protect_app_role_id
  after_save :update_order

  protect_account_forgery :user, :emp_position

  def update_defaults
    self.name = app_role.name

    if self.emp_position_id && self.emp_position_position.nil?
      q = emp_position.user_roles
      q = q.where("id != ?", self.id) unless new_record?
      m = q.maximum("emp_position_position")
      self.emp_position_position = m ? m + 1 : 1
    end

    if self.geo_area_id && self.geo_area_position.nil?
      q = geo_area.user_roles
      q = q.where("id != ?", self.id) unless new_record?
      m = q.maximum("geo_area_position")
      self.geo_area_position = m ? m + 1 : 1
    end
  end

  def protect_app_role_id
    if app_role_id_changed? && self.account.app_role_set_id != app_role.app_role_set_id
      raise "AppRoleSet #{app_role.app_role_set_id} doesn't not belong to Account #{self.account_id}"
    end
  end

  def update_order
    if emp_position_id_changed? || deleted_at_changed?
      EmpPosition::AsEdit.update_order(self.account_id)
    end
  end

  def deactivate
    self.deleted_at = Time.now
  end

  def can_destroy?
    true
  end

end
