# == Schema Information
#
# Table name: org_unit_searches
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

class OrgUnitSearch < ApplicationRecord
  include AccountScoped

  belongs_to :user_role

  normalize_attributes :query, :name, :city, :street, :collab, :visits_cond, :visits_state
  normalize_attributes :tags_ids, with: [ :pg_array => { :integers => true } ]
  normalize_attributes :wo_tags_ids, with: [ :pg_array => { :integers => true } ]

  validates :collab, inclusion: { in: OrgUnit::COLLAB_VALUES }, allow_nil: true

  def set_defaults
    self.do_search = false
    self.query = nil
    self.collab = nil
    self.tags_ids = []
    self.wo_tags_ids = []
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
      SELECT o.*
      FROM org_units o
      INNER JOIN org_unit_addresses oa ON
        oa.org_unit_id = o.id AND
        oa.deleted_at is null AND
        oa.category = :addr_category
      INNER JOIN addresses a ON
        a.id = oa.address_id
      WHERE "
    h[:addr_category] = OrgUnitAddress::ADDR_MAIN

    if query
      parts = RwStringExt.simplify(query).split(/\s+/)
      parts.each do |part|
        part = "%#{c.quote_string(part)}%"
        s << "(o.searchable_name LIKE '#{part}' OR
               a.searchable_addr LIKE '#{part}') AND "
      end
    end

    if tags_ids.size > 0
      tags_ids_q = tags_ids.join(',')
      s << "o.id IN (
        SELECT DISTINCT taggable_id
        FROM taggings t
        WHERE
          t.tag_id IN (#{tags_ids_q}) AND
          t.taggable_type = 'OrgUnit' AND
          t.deleted_at IS NULL AND
          t.account_id = :account_id
      ) AND "
    end

    if wo_tags_ids.size > 0
      wo_tags_ids_q = wo_tags_ids.join(',')
      s << "o.id NOT IN (
        SELECT DISTINCT taggable_id
        FROM taggings t
        WHERE
          t.tag_id IN (#{wo_tags_ids_q}) AND
          t.taggable_type = 'OrgUnit' AND
          t.deleted_at IS NULL AND
          t.account_id = :account_id
      ) AND "
    end

    if collab
      s << "o.collab = '#{c.quote_string(collab)}' AND "
    end

    s << "o.deleted_at is null AND
          o.account_id = :account_id
          ORDER BY o.name"
    h[:account_id] = Account.current.id

    if per_page
      sql = self.class.send(:sanitize_sql, [s, h])
      res_count = OrgUnit.count_by_sql "SELECT COUNT(DISTINCT p.id) FROM (#{sql}) p"
      OrgUnit.paginate_by_sql(sql, page: page, per_page: per_page, total_entries: res_count)
    else
      OrgUnit.find_by_sql [s, h]
    end
  end

  def show_advanced?
    tags_begin || tags_end || wo_tags_ids.size > 0
  end

end
