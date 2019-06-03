class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.account_scoped?
    false
  end

end
