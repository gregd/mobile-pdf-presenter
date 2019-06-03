m = Aorm::Model.new("repo_file", "repo_files", local_table: true)
m.column "repo_name",   :string2
m.column "repo_item_id",:integer
m.column "hash",        :string2
m.column "state",       :string2
m.column "mime_type",   :string2  # to delete, do not use
m.column "size",        :long
m.column "repo_path",   :string
m.column "local_path",  :string

m.index "repo_item_id"
m.index "hash"

m.belongs_to "repo_item", "item", "repo_item_id"
