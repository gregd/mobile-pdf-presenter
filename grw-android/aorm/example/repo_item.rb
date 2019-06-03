m = Aorm::Model.new("repo_item", "repo_items", local_table: true)
m.column "repo_revision_id",  :integer
m.column "path",              :string
m.column "type",              :string2
m.column "hash",              :string2
m.column "size",              :long

m.index "repo_revision_id"
m.index "hash"

m.belongs_to "repo_revision", "revision", "repo_revision_id"
m.has_one "repo_file", "file", foreign_key: "repo_item_id"
