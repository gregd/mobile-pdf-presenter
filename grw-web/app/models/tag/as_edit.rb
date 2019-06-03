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

class Tag::AsEdit < Tag
  include ExtendedModel

  acts_as_list scope: :tag_group

  normalize_attributes :name, :abbr, :color

  validates :position, presence: true
  validates :tag_group_id, presence: true
  validates :name, presence: true
  validates :abbr, presence: true
  validates :description, presence: true
  validates :default_tag, inclusion: { in: [true, false] }

  before_validation :set_defaults

  def set_defaults
    self.position = (self.class.maximum(:position) || 0) + 1 if position.nil?
    self.default_tag = false  if default_tag.nil?
  end

end
