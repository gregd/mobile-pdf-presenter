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

class EmpPosition::AsEdit < EmpPosition
  include ExtendedModel
  validates :name, presence: true

  before_destroy :can_destroy?

  protect_account_forgery :parent

  def can_destroy?
    user_roles.count == 0
  end

  def self.can_add_new?
    EmpPosition.active.count < Account.current.account_plan.max_emp_positions
  end

  def self.update_order(account_id)
    account_id = Account.current.id if account_id.nil?
    main_position = 1

    exec_sql <<-SQL
      update emp_positions
      set node_name = a.name, user_role_id = a.ur_id
      from (
        select
          ep.id as id,
          coalesce(u.last_name || ' ' || u.first_name, ep.name) as name,
          ur.id as ur_id
        from emp_positions ep
        left join user_roles ur on
          ur.emp_position_id = ep.id and
          ur.emp_position_position = #{main_position} and
          ur.deleted_at is null
        left join users u on
          u.id = ur.user_id
        where
          ep.account_id = #{account_id} and
          ep.deleted_at is null
        ) a
      where a.id = emp_positions.id
    SQL

    roots.where(account_id: account_id).each do |root_node|
      offset = 0
      exec_sql <<-SQL
        update #{table_name}
        set node_order = #{offset} + real_pos
        from (
          with recursive table_tree as (
            select id, 0 as level, node_name::text as breadcrumb
            from #{table_name} where id = #{root_node.id}
            union all
            select c.id, p.level + 1 as level, p.breadcrumb || c.node_name
            from table_tree p
            inner join #{table_name} c on p.id = c.parent_id)
          select
            id, level, row_number() over(order by breadcrumb) as real_pos
          from table_tree) a
        where a.id = #{table_name}.id
      SQL
    end
  end

end
