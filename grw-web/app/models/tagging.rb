# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  account_id    :integer
#  uuid          :uuid
#  user_role_id  :integer
#  tag_id        :integer
#  taggable_uuid :uuid
#  taggable_id   :integer
#  taggable_type :string
#  main_tagging  :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :datetime
#  lock_version  :integer          default(0)
#

class Tagging < ApplicationRecord
  include AccountScoped
  include WithPresenter

  belongs_to :user_role
  belongs_to :tag
  belongs_to :taggable, polymorphic: true

  scope :active, -> { where("taggings.deleted_at IS NULL") }

end
