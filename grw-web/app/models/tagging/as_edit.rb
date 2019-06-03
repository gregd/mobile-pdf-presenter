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

class Tagging::AsEdit < Tagging
  include ExtendedModel

  validates :uuid, presence: true
  validates :user_role_id, presence: true
  validates :tag_id, presence: true
  validates :taggable_uuid, presence: true
  validates :taggable_type, presence: true
  validates :taggable_id, presence: true
  validates :main_tagging, inclusion: { in: [true, false] }

  protect_account_forgery :tag, :taggable

  before_validation :set_defaults

  def set_defaults
    self.uuid = SecureRandom.uuid unless uuid
    self.taggable_uuid = taggable.uuid unless taggable_uuid
  end

  def self.load_taggable(type, id)
    case type
      when "Person"
        Person.find(id)
      when "OrgUnit"
        OrgUnit.find(id)
      else
        raise "Taggable unknown #{type}/#{id}"
    end
  end

  def self.sync_taggings(ur, taggable, group, tags_ids)
    Tagging.transaction do
      existing = []
      taggable.taggings.joins(:tag).where("tags.tag_group_id = ?", group.id).each do |t|
        if tags_ids.include?(t.tag_id)
          existing << t.tag_id
        else
          t.user_role_id = ur.id
          t.deleted_at = Time.now
          t.save!
        end
      end
      (tags_ids - existing).each do |tag_id|
        Tagging::AsEdit.create!(
          user_role_id: ur.id,
          tag_id:       tag_id,
          taggable:     taggable,
          main_tagging: false)
      end
    end
  end

  def self.add_to(ur, taggables, tag)
    added = 0
    Tagging.transaction do
      taggables.each do |taggable|
        next if taggable.taggings.where("tag_id = ?", tag.id).count > 0
        Tagging::AsEdit.create!(
          user_role_id: ur.id,
          tag_id:       tag.id,
          taggable:     taggable,
          main_tagging: false)
        added += 1
      end
    end

    added
  end

end
