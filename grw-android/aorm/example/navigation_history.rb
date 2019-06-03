m = Aorm::Model.new("navigation_history", "navigation_histories")
m.column "user_id",       :integer
m.column "category",      :string2
m.column "action",        :string2
m.column "object_type",   :string2
m.column "object_uuid",   :string2
m.column "object_id",     :integer
m.column "extra1",        :string2
m.column "extra2",        :string2
m.column "description",   :string
m.column "created_at",    :date
m.column "updated_at",    :date

m.index "updated_at"
m.index "object_uuid"
