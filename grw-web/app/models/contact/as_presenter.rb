# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  uuid             :uuid
#  contactable_uuid :uuid
#  contactable_id   :integer
#  contactable_type :string
#  category         :string
#  address          :string
#  comments         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  lock_version     :integer          default(0)
#

class Contact::AsPresenter < Contact
  include ExtendedModel

  def view_category
    CATEGORIES_MAP[category]
  end

  def view_short_link
    case category
      when "phone"
        h.content_tag :a, address, callto: address
      when "email"
        h.content_tag :a, "email", href: "mailto:#{address}"
      when "www"
        h.content_tag :a, "www", href: address, target: "_blank"
    end
  end

end
