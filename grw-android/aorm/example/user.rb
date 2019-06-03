m = Aorm::Model.new("user", "users")
m.column  "first_name", :string
m.column  "last_name",  :string
m.column  "email",      :string
m.column  "phone",      :string
m.column  "deleted_at", :date

m.has_many "user_role", "userRoles", where: "user_roles.deleted_at IS NULL", foreign_key: "user_id"
m.has_one "user_mobile_option", "mobileOption", foreign_key: "user_id"
#m.has_many "user_address", "addresses", where: "deleted_at IS NULL", foreign_key: "user_id"
