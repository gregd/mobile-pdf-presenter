# == Schema Information
#
# Table name: tracker_files
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  repo_name       :string
#  git_hash        :string
#  rel_path        :text
#  tracker_item_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class TrackerFile < ApplicationRecord
  include AccountScoped
  belongs_to :tracker_item
  has_many :tracker_file_events, foreign_key: :tracking_id, dependent: :delete_all
  has_many :tracker_file_states, foreign_key: :tracking_id, dependent: :delete_all

  validates :repo_name, presence: true
  validates :git_hash, presence: true, length: { is: 40 }
  validates :rel_path, presence: true

  def self.get_tracking_id(repo_name, git_hash, rel_path, mime_type, content_info, required_id)
    ob = where(repo_name: repo_name, git_hash: git_hash, rel_path: rel_path).first
    return ob.id if ob

    item_id = find_item_id(repo_name, git_hash, File.basename(rel_path, ".*"), mime_type, content_info)

    ob = new(repo_name: repo_name, git_hash: git_hash, rel_path: rel_path, tracker_item_id: item_id)
    ob.id = required_id if required_id
    ob.save!
    ob.id
  end

  def self.find_item_id(repo_name, git_hash, base_name, mime_type, content_info)
    same_hash = where(repo_name: repo_name, git_hash: git_hash).order("created_at DESC").first
    if same_hash
      item = same_hash.tracker_item
      if item.base_name != base_name
        item.base_name = base_name
        item.save!
      end
      item.id

    else
      TrackerItem.get_item_id(repo_name, base_name, mime_type, content_info)
    end
  end

end
