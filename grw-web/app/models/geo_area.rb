# == Schema Information
#
# Table name: geo_areas
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  parent_id      :integer
#  path           :ltree
#  name           :string
#  geo_brick_id   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deleted_at     :datetime
#  max_depth      :integer
#  children_count :integer
#  node_name      :integer
#  node_order     :integer
#

class GeoArea < ApplicationRecord
  include AccountScoped
  has_ltree_hierarchy

  belongs_to :geo_brick, optional: true
  has_many :user_roles, -> { active }

  before_validation :set_defaults

  def set_defaults
    self.max_depth = parent.max_depth unless max_depth
  end

  def validate_membership(args, errors)
    return unless args.has_key?(:zipcode) && args[:zipcode].present?

    geo_partition = Account.current.geo_partition
    geo_brick = geo_partition.brick_for_zipcode(args[:zipcode])

    unless geo_brick
      errors.add(:zipcode, "Kod pocztowy '#{args[:zipcode]}' nie został znaleziony w bazie.")
      return
    end

    unless brick_ids.include?(geo_brick.id)
      errors.add(:zipcode, "Obszar '#{name}' nie posiada dostępu do kodu '#{args[:zipcode]}'")
    end
  end

  def brick_ids
    self_and_descendants.where("geo_brick_id IS NOT NULL").pluck(:geo_brick_id)
  end

end
