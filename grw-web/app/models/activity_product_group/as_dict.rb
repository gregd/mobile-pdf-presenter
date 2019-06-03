# == Schema Information
#
# Table name: activity_product_groups
#
#  id         :integer          not null, primary key
#  account_id :integer
#  klasses    :string           default([]), not null, is an Array
#  position   :integer
#  name       :string
#  abbr       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class ActivityProductGroup::AsDict < ActivityProductGroup
  include ExtendedModel

  def self.for_products
    active.order("position").map {|g| [g.name, g.id] }
  end

end
