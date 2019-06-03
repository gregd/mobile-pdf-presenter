m = Aorm::Model.new("tracker_file_event", "tracker_file_events")
m.syncable_columns
m.column "user_role_id",        :integer
m.column "mobile_device_id",    :integer
m.column "trackable_type",      :string2
m.column "trackable_uuid",      :string2
m.column "trackable_id",        :integer
m.column "tracking_id",         :integer
m.column "page",                :integer
m.column "beginning",           :integer
m.column "duration",            :long
m.timestamp_columns                       # deleted_at might be used in future
