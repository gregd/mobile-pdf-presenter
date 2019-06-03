m = Aorm::Model.new("app_role", "app_roles")
m.column  "position",         :integer
m.column  "name",             :string
m.column  "cap_presenter",    :bool
m.column  "cap_location",     :bool
m.column  "cap_projects",     :bool
m.column  "cap_crm",          :bool
m.column  "extra_attrs",      :string
