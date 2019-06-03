# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  tag_group_id   :integer
#  parent_id      :integer
#  path           :ltree
#  children_count :integer
#  position       :integer
#  name           :string
#  abbr           :string
#  description    :string
#  color          :string
#  default_tag    :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#

class Tag < ApplicationRecord
  include AccountScoped
  include WithPresenter

  belongs_to :tag_group
  has_many :taggings, -> { active }

  scope :active, -> { where("tags.deleted_at IS NULL") }

end
