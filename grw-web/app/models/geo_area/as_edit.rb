# == Schema Information
#
# Table name: geo_areas
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  parent_id      :integer
#  path           :ltree
#  name           :string
#  geo_brick_id   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  max_depth      :integer
#  children_count :integer
#  node_name      :integer
#  node_order     :integer
#

class GeoArea::AsEdit < GeoArea
  include ExtendedModel

  protect_account_forgery :parent

  def can_destroy?
    children.count == 0
  end

end
