# == Schema Information
#
# Table name: activity_visits
#
#  id                        :integer          not null, primary key
#  account_id                :integer
#  uuid                      :uuid
#  creator_role_id           :integer
#  user_role_id              :integer
#  org_unit_id               :integer
#  address_id                :integer
#  address_uuid              :uuid
#  validity_state            :string
#  klass                     :string
#  activity_on               :date
#  begin_at                  :datetime
#  end_at                    :datetime
#  has_time                  :boolean          default(FALSE), not null
#  activity_stage            :string
#  planned_at                :datetime
#  approved_at               :datetime
#  reported_at               :datetime
#  cancelled_at              :datetime
#  missed_at                 :datetime
#  comments                  :text
#  form_category             :string
#  products_ids              :integer          default([]), not null, is an Array
#  extra_attrs               :jsonb            not null
#  has_checkin               :boolean          default(FALSE), not null
#  active_participants_count :integer          default(0), not null
#  active_attachments_count  :integer          default(0), not null
#  user_updated_at           :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  deleted_at                :datetime
#  lock_version              :integer          default(0)
#

class ActivityVisit::AsReported < ActivityVisit
  include ExtendedModel

end
