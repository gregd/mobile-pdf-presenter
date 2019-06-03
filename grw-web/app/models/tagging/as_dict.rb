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

class Tagging::AsDict < Tagging
  include ExtendedModel

  def self.grouped_for(taggable)
    map = active.
      where(taggable: taggable).
      includes(:tag).
      order("tags.position").
      group_by {|t| t.tag.tag_group_id }

    groups = TagGroup::AsDict.for_klass(taggable.class.model_name.name)

    groups.map do |g|
      [g, map[g.id] || []]
    end
  end

end
