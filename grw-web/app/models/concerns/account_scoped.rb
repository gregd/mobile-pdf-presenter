module AccountScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account

    default_scope { Account.current.nil? ? all : where("#{table_name}.account_id = ?", Account.current.id) }

    before_validation Proc.new {|m| m.account_id = Account.current.id if m.account_id.nil? }, :on => :create

    validates :account_id, presence: true

    before_save :protect_account_ids

    cattr_accessor :protected_account_associations, instance_writer: false do [] end

    def protect_account_ids
      protected_account_associations.each do |name|
        key = self.class.reflect_on_association(name).foreign_key
        if self.send(key) && self.send("#{key}_changed?")
          ob = self.send(name)
          raise "No dependent object" if ob.nil?
          raise "Account forgery"     if self.account_id != ob.account_id
        end
      end
    end
  end

  class_methods do
    def account_scoped?
      true
    end

    def protect_account_forgery(*associations)
      protected_account_associations.concat(associations)
    end
  end

end
