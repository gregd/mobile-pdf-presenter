# == Schema Information
#
# Table name: general_comments
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  uuid             :uuid
#  user_role_id     :integer
#  commentable_uuid :uuid
#  commentable_id   :integer
#  commentable_type :string
#  category         :string
#  comments         :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  lock_version     :integer          default(0)
#

class GeneralComment < ApplicationRecord
  include AccountScoped
  include SyncModel
  belongs_to :user_role
  belongs_to :commentable, polymorphic: true

  scope :active, -> { where("general_comments.deleted_at IS NULL") }

end
