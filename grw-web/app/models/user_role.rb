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

class UserRole < ApplicationRecord
  include AccountScoped
  belongs_to :user
  belongs_to :app_role
  belongs_to :emp_position, optional: true
  belongs_to :geo_area, optional: true

  scope :active, -> { where("user_roles.deleted_at IS NULL") }

  def reporting_emp(requested_emp_id)
    emp_position.reporting_emp(requested_emp_id)
  end

  def reporting_emps(filter: :self_and_all, order: :hierarchy, cond: nil)
    emp_position.reporting_emps(filter: filter, order: order, cond: cond)
  end

  def validate_membership(args, errors)
    if geo_area_id
      geo_area.validate_membership(args, errors)
    end
    # add eco sector
  end

  def self.set_current(ur)
    RequestStore.store[:current_user_role] = ur
  end

  def self.current
    RequestStore.store[:current_user_role]
  end

end
