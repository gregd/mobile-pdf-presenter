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

class EmpPosition::AsDict < EmpPosition
  include ExtendedModel

  def tree_name
    "#{'- ' * (depth - 1)} #{name}"
  end

  def self.for_users
    order("path").
      map {|e| [e.tree_name, e.id] }
  end

end
