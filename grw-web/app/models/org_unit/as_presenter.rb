# == Schema Information
#
# Table name: org_units
#
#  id                :integer          not null, primary key
#  account_id        :integer
#  uuid              :uuid
#  owner_id          :integer
#  collab            :string
#  name              :string
#  tax_nip           :string
#  searchable_name   :string
#  active_jobs_count :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  lock_version      :integer          default(0)
#  master_id         :integer
#

class OrgUnit::AsPresenter < OrgUnit
  include ExtendedModel

  def view_name
    name
  end

end
