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

class Person::AsPresenter < Person
  include ExtendedModel

  def view_name
    "#{last_name} #{first_name}"
  end

end
