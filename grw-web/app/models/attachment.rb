# == Schema Information
#
# Table name: attachments
#
#  id                 :integer          not null, primary key
#  account_id         :integer
#  uuid               :uuid
#  owner_uuid         :uuid
#  owner_type         :string
#  owner_id           :integer
#  category           :string
#  asset_file_name    :string
#  asset_content_type :string
#  asset_file_size    :integer
#  asset_updated_at   :datetime
#  lat                :float
#  lng                :float
#  ll_raw_info        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted_at         :datetime
#  lock_version       :integer          default(0)
#

class Attachment < ApplicationRecord
  include AccountScoped

  belongs_to :owner, polymorphic: true

end
