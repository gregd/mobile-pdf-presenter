# == Schema Information
#
# Table name: persons
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  uuid            :uuid
#  collab          :string
#  person_title_id :integer
#  first_name      :string
#  last_name       :string
#  unknown_name    :boolean          default(FALSE), not null
#  searchable_name :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#  lock_version    :integer          default(0)
#  master_id       :integer
#

class Person::AsEdit < Person
  include ExtendedModel

  normalize_attributes :first_name, :last_name

  validates :uuid, presence: true
  validates :person_title_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :collab, presence: true, inclusion: { in: OrgUnit::COLLAB_VALUES }

  before_validation :set_defaults, :normalize_fields

  protect_account_forgery :person_title

  def set_defaults
    self.uuid = SecureRandom.uuid unless uuid
  end

  def normalize_fields
    if first_name_changed? || last_name_changed?
      self.searchable_name = normalized_name
    end
  end

  def normalized_name
    %i(first_name last_name).map do |col|
      val = send(col)
      val.present? ? RwStringExt.simplify(val) : nil
    end.compact.join(" ")
  end

end
