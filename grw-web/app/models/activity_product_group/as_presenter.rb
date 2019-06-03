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

class ActivityProductGroup::AsPresenter < ActivityProductGroup
  include ExtendedModel

  def view_klasses
    klasses.map {|k| KLASSES_MAP[k] }
  end

end
