# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  subdomain        :string
#  company          :string
#  account_plan_id  :integer
#  app_role_set_id  :integer
#  geo_partition_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#

class Account::Cleaner < Account
  include ExtendedModel

  def self.remove_account!(aid)
    transaction do
      # iterate objects with attachments
      MobileLog.where(account_id: aid).where("asset_file_name IS NOT NULL").each {|ml| ml.destroy }

      # delete db records
      model_klasses.each do |klass|
        klass.where(account_id: aid).delete_all
      end

      # delete main account record
      self.where(id: aid).delete_all

      # delete files repo
      Repo::Git.remove_repo(aid)
    end
  end

  def self.model_klasses
    prefix_chars = File.join(Rails.root, "app", "models").size + 1

    Dir[Rails.root.join('app/models/**/*.rb')].map do |path|
      model_file = path[prefix_chars .. -4]
      next if model_file.start_with?("concerns")
      klass = model_file.camelize.constantize
      (klass < ApplicationRecord && klass.account_scoped?) ? klass : nil
    end.compact
  end

end
