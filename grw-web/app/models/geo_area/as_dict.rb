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

class GeoArea::AsDict < GeoArea
  include ExtendedModel

  def tree_name
    "#{'- ' * (depth - 1)} #{name}"
  end

  def self.for_users
    return [] unless Account.current.has_geo_structure?
    where("nlevel(path) < max_depth").
      order("path").
      map {|e| [e.tree_name, e.id] }
  end

end
