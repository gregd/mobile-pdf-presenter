m = Aorm::Model.new("tracker_app_event", "tracker_app_events", trigger_upload: false)
m.syncable_columns
m.column "user_role_id",        :integer
m.column "app_version",         :integer
m.column "mobile_device_id",    :integer
m.column "person_id",           :integer
m.column "institution_id",      :integer
m.column "screen",              :string2
m.column "category",            :string2
m.column "action",              :string2
m.column "label",               :string2
m.column "value",               :long
m.timestamp_columns
