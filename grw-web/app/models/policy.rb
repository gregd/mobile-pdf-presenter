class Policy
  extend ActiveModel::Naming

  attr_reader :errors

  def initialize(object, user_role)
    @policy_object = object
    @policy_user_role = user_role
    @errors = ActiveModel::Errors.new(self)
  end

  delegate :new_record?, to: :@policy_object

  # required by ActiveModel::Errors
  delegate :read_attribute_for_validation, to: :@policy_object

  def self.human_attribute_name(attr, options = {})
    policy_object_klass.human_attribute_name(attr, options)
  end

  def self.lookup_ancestors
    policy_object_klass.lookup_ancestors
  end

  def self.policy_object_klass
    @policy_object_klass ||= name.gsub(/Policy$/, '').constantize
  end

end
