module SyncModel
  extend ActiveSupport::Concern

  included do
    attr_accessor :client_updated_at
    attr_accessor :lock_version unless column_names.include?("lock_version")
  end

  # class_methods do
  # end

end