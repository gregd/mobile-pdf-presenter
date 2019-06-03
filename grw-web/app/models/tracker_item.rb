# == Schema Information
#
# Table name: tracker_items
#
#  id         :integer          not null, primary key
#  account_id :integer
#  repo_name  :string
#  base_name  :string
#  mime_type  :string
#  pages      :integer
#  seconds    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class TrackerItem < ApplicationRecord
  include AccountScoped
  PDF_TYPES   = ['application/pdf'].freeze
  VIDEO_TYPES = ['video/mp4'].freeze

  has_many :tracker_files, -> { order("git_hash, rel_path") }, dependent: :destroy

  scope :active, -> { where("deleted_at IS NULL") }
  scope :content_pdf, -> { where("mime_type IN (?)", PDF_TYPES) }
  scope :options, ->(repo_name) { where(repo_name: repo_name).order("base_name, created_at DESC") }

  def pdf?
    PDF_TYPES.include?(self.mime_type)
  end

  def video?
    VIDEO_TYPES.include?(self.mime_type)
  end

  def deactivate!
    self.deleted_at = Time.now
    save!
  end

  def self.get_item_id(repo_name, base_name, mime_type, content_info)
    ob = active.
      where(repo_name: repo_name,
            base_name: base_name,
            mime_type: mime_type).
      order("created_at DESC").first
    return ob.id if ob

    ob = create!(repo_name: repo_name, base_name: base_name, mime_type: mime_type,
                 pages: content_info[:pages], seconds: content_info[:seconds])
    ob.id
  end

  def self.possible_for(file)
    item = file.tracker_item
    q = active.where(mime_type: item.mime_type)
    q = q.where("id != ?", item.id)
    if item.pages
      b1 = (item.pages * 0.9).round
      b2 = (item.pages * 1.1).round
      q = q.where("pages BETWEEN ? AND ?", b1, b2)
    elsif item.seconds
      b1 = (item.seconds * 0.9).round
      b2 = (item.seconds * 1.1).round
      q = q.where("seconds BETWEEN ? AND ?", b1, b2)
    end
    q
  end

end
