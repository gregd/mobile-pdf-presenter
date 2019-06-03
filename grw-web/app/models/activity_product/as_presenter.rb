# == Schema Information
#
# Table name: activity_products
#
#  id                        :integer          not null, primary key
#  account_id                :integer
#  activity_product_group_id :integer
#  position                  :integer
#  name                      :string
#  abbr                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  deleted_at                :datetime
#  lock_version              :integer          default(0)
#

class ActivityProduct::AsPresenter < ActivityProduct
  include ExtendedModel

  def view_as_label
    abbr
  end

end
