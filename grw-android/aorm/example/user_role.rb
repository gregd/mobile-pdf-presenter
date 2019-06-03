m = Aorm::Model.new("user_role", "user_roles")
m.column  "user_id",        :integer
m.column  "app_role_id",    :integer
m.column  "emp_position_id",:integer
m.column  "geo_area_id",    :integer
m.column  "eco_sector_id",  :integer
m.column  "name",           :string
m.column  "deleted_at",     :date

m.index   "user_id"

m.belongs_to "user", "user", "user_id"
m.belongs_to "app_role", "appRole", "app_role_id"

# m.has_many "report_deadline", "activeDeadlines", where: <<-SQL.strip, str_arg: "klass"
#   "user_role_id = " + mid + " AND " +
#   "klass = " + e(klass) + " AND " +
#   "end_on >= " + com.grw.mobi.util.DateUtils.today().getTime() + " AND " +
#   "report_deadlines.deleted_at IS NULL"
# SQL
