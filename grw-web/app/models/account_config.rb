# == Schema Information
#
# Table name: account_configs
#
#  id                  :integer          not null, primary key
#  account_id          :integer
#  daily_report_emails :string           default([]), not null, is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  deleted_at          :datetime
#

class AccountConfig < ApplicationRecord
  include AccountScoped

  scope :active, -> { where("account_configs.deleted_at IS NULL") }

  def daily_report_emails=(arguments)
    super(arguments.present? ? arguments.split(",").map {|a| a.strip }.select {|a| a.present? } : [])
  end

end
