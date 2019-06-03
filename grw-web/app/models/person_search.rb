# == Schema Information
#
# Table name: person_searches
#
#  id                  :integer          not null, primary key
#  account_id          :integer
#  user_role_id        :integer
#  do_search           :boolean          default(FALSE), not null
#  query               :string
#  name                :string
#  collab              :string
#  geo_area_id         :integer
#  city                :string
#  street              :string
#  cities              :string           default([]), is an Array
#  streets             :string           default([]), is an Array
#  tags_ids            :integer          default([]), is an Array
#  tags_begin          :date
#  tags_end            :date
#  wo_tags_ids         :integer          default([]), is an Array
#  wo_tags_begin       :date
#  wo_tags_end         :date
#  ou_tags_ids         :integer          default([]), is an Array
#  ou_tags_begin       :date
#  ou_tags_end         :date
#  wo_ou_tags_ids      :integer          default([]), is an Array
#  wo_ou_tags_begin    :date
#  wo_ou_tags_end      :date
#  visits_cond         :string
#  visits_state        :string
#  visits_begin        :date
#  visits_end          :date
#  visits_user_role_id :integer
#  page                :integer
#  per_page            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class PersonSearch < ApplicationRecord
  include AccountScoped

  belongs_to :user_role

  normalize_attributes :query, :name, :collab, :city, :street, :visits_cond, :visits_state
  normalize_attributes :tags_ids, with: [ :pg_array => { :integers => true } ]
  normalize_attributes :wo_tags_ids, with: [ :pg_array => { :integers => true } ]
  normalize_attributes :ou_tags_ids, with: [ :pg_array => { :integers => true } ]

  validates :collab, inclusion: { in: OrgUnit::COLLAB_VALUES }, allow_nil: true

  def set_defaults
    self.do_search = false
    self.query = nil
    self.collab = nil
    self.tags_ids = []
    self.wo_tags_ids = []
    self.ou_tags_ids = []
    self.wo_ou_tags_ids = []
    self.per_page = 10
  end

  def set_params(args)
    set_defaults
    self.attributes = args
    self.do_search = true
  end

  def self.get_for(user_role)
    s = where(user_role_id: user_role.id).first
    return s if s
    s = new
    s.user_role = user_role
    s.set_defaults
    s.save!
    s
  end

  def execute
    c = self.class.connection
    h = {}
    s = "
      SELECT p.*
      FROM persons p
      WHERE "

    if query
      parts = RwStringExt.simplify(query).split(/\s+/)
      parts.each do |part|
        part = "%#{c.quote_string(part)}%"
        s << "(p.searchable_name LIKE '#{part}') AND "
      end
    end

    if tags_ids.size > 0
      tags_ids_q = tags_ids.join(',')
      s << "p.id IN (
        SELECT DISTINCT taggable_id
        FROM taggings t
        WHERE
          t.tag_id IN (#{tags_ids_q}) AND
          t.taggable_type = 'Person' AND
          t.deleted_at IS NULL AND
          t.account_id = :account_id
      ) AND "
    end

    if wo_tags_ids.size > 0
      wo_tags_ids_q = wo_tags_ids.join(',')
      s << "p.id NOT IN (
        SELECT DISTINCT taggable_id
        FROM taggings t
        WHERE
          t.tag_id IN (#{wo_tags_ids_q}) AND
          t.taggable_type = 'Person' AND
          t.deleted_at IS NULL AND
          t.account_id = :account_id
      ) AND "
    end

    if ou_tags_ids.size > 0
      ou_tags_ids_q = ou_tags_ids.join(',')
      s << "p.id IN (
        SELECT DISTINCT pj.person_id
        FROM person_jobs pj
        WHERE
          pj.account_id = :account_id AND
          pj.deleted_at IS NULL AND
          pj.org_unit_id IN (
            SELECT DISTINCT taggable_id
            FROM taggings t
            WHERE
              t.tag_id IN (#{ou_tags_ids_q}) AND
              t.taggable_type = 'OrgUnit' AND
              t.deleted_at IS NULL AND
              t.account_id = :account_id)
      ) AND "
    end

    if collab
      s << "p.collab = '#{c.quote_string(collab)}' AND "
    end

    s << "p.deleted_at is null AND
          p.account_id = :account_id
          ORDER BY p.last_name, p.first_name"
    h[:account_id] = Account.current.id

    if per_page
      sql = self.class.send(:sanitize_sql, [s, h])
      res_count = Person.count_by_sql "SELECT COUNT(DISTINCT p.id) FROM (#{sql}) p"
      Person.paginate_by_sql(sql, page: page, per_page: per_page, total_entries: res_count)
    else
      Person.find_by_sql [s, h]
    end
  end

  def show_advanced?
    tags_begin || tags_end || wo_tags_ids.size > 0
  end

end
