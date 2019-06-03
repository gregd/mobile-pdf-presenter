m = Aorm::Model.new("general_comment", "general_comments")
m.syncable_columns
m.column "user_role_id",      :integer
m.column "commentable_id",    :integer, updated: true
m.column "commentable_uuid",  :string2
m.column "commentable_type",  :string2
m.column "category",          :string2
m.column "comments",          :string
m.column "extra_attrs",       :string
m.timestamp_columns

m.index "commentable_id"

#m.belongs_to "location_summary", "summary", "location_summary_id"

m.remember ["user_role_id", "commentable_id", "commentable_uuid", "commentable_type", "category", "comments", "extra_attrs"]
