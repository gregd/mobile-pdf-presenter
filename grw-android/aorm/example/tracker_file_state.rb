m = Aorm::Model.new("tracker_file_state", "tracker_file_states")
m.syncable_columns
m.column "user_role_id",        :integer
m.column "trackable_type",      :string2
m.column "trackable_uuid",      :string2
m.column "trackable_id",        :integer
m.column "tracking_id",         :integer
m.column "page",                :integer
m.column "position",            :integer
m.column "progress",            :integer
m.column "extras",              :string2
m.timestamp_columns

m.index  "trackable_type"
m.index  "trackable_uuid"
