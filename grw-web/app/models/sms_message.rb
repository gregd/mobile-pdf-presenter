# == Schema Information
#
# Table name: sms_messages
#
#  id            :integer          not null, primary key
#  account_id    :integer
#  user_id       :integer
#  mobile_number :string
#  text_message  :string
#  status        :string
#  response      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class SmsMessage < ApplicationRecord
  include AccountScoped
  belongs_to :user

  validates :mobile_number, :format => { :with => /(48)?\d{9}/ }
  validates :status, :inclusion => ['init', 'sent', 'api_error', 'net_error', 'parse_error']

  normalize_attributes(:mobile_number) {|n| n.nil? ? nil : n.gsub(/\s+/, '') }

  after_initialize :set_default_values
  before_save :clean_fields

  def set_default_values
    self.status = 'init' if self.status.nil?
  end

  def sent?
    self.status == 'sent'
  end

  def send_via_api
    raise "Invalid one-time password SMS" unless valid?
    self.status, self.response = SmsMessage::SmsApi.send(mobile_number, text_message)
    sent?
  end

  def clean_fields
    if status == 'sent'
      # don't save the text message because it might contain a password
      self.text_message = nil
    end
  end

end
