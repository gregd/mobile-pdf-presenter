m = Aorm::Model.new("repo_revision", "repo_revisions", local_table: true)
m.column "repo_name",     :string2
m.column "hash",          :string2
m.column "state",         :string2
m.column "modified_at",   :date
m.column "items_count",   :integer
m.column "missing_count", :integer
m.column "unlinked_count", :integer
m.column "notification_count", :integer

m.has_many "repo_item", "items", foreign_key: "repo_revision_id"
