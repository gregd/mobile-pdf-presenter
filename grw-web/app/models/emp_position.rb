# == Schema Information
#
# Table name: emp_positions
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  parent_id      :integer
#  path           :ltree
#  name           :string
#  user_role_id   :integer
#  node_order     :integer
#  node_name      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  max_depth      :integer
#  children_count :integer
#

class EmpPosition < ApplicationRecord
  include AccountScoped
  has_ltree_hierarchy

  has_many :user_roles, -> { active }
  belongs_to :user_role, optional: true

  before_validation :set_defaults

  scope :active, -> { where("deleted_at IS NULL") }

  def set_defaults
    self.max_depth = parent.max_depth unless max_depth
  end

  def reporting_emp(requested_emp_id)
    allowed_ids = self_and_descendants.pluck(:id)
    return nil unless allowed_ids.include?(requested_emp_id)
    self.class.find(requested_emp_id)
  end

  def reporting_emps(filter: :self_and_all, order: :hierarchy, cond: nil)
    depth_offset = self.depth - 1
    depth_offset += 1 if filter != :self_and_all

    q = <<-SQL
      select
        ep.*,
        nlevel(ep.path) - #{ depth_offset } as relative_level
      from
        emp_positions ep
      left join user_roles ur on
        ep.user_role_id = ur.id
      left join users u on
        u.id = ur.user_id
      left join app_roles ar on
        ar.id = ur.app_role_id
      where
        ep.account_id = #{ self.account_id } and
        ep.deleted_at is null and
    SQL

    case filter
      when :self_and_all
        q = q + "ep.path <@ '#{ self.path }'"

      when :all
        q = q + "ep.path <@ '#{ self.path }' and ep.id != #{ self.id }"

      when :direct
        q = q + "ep.parent_id = #{ self.id }"

      else
        raise "Wrong filter type"
    end

    if cond
      q = q + " and #{cond} "
    end

    case order
      when :hierarchy
        q = q + " order by ep.node_order"
      when :names
        q = q + " order by ep.node_name"
      else
        raise "Wrong order type"
    end

    EmpPosition.find_by_sql(q)
  end

end
