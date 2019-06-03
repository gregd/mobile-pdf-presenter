class TrackerAppEvent::AdminFilter < ActiveType::Object
  attribute :account, :string
  attribute :device_ui, :string
  attribute :screen, :string
  attribute :category, :string
  attribute :action, :string
  attribute :label, :string
  attribute :start_on, :date
  attribute :end_on, :date
  attribute :page, :integer
  attribute :per_page, :integer

  def events
    q = TrackerAppEvent.
      order("id DESC").
      page(self.page).
      per_page(self.per_page)

    q = q.where("screen ILIKE ?", "#{screen}%")               if screen
    q = q.where("category ILIKE ?", "#{category}%")           if category
    q = q.where("action ILIKE ?", "#{action}%")               if action
    q = q.where("label ILIKE ?", "#{label}%")                 if label
    q = q.where("created_at >= ?", start_on.beginning_of_day) if start_on
    q = q.where("created_at <= ?", end_on.end_of_day)         if end_on

    if account.present?
      a = Account.where(subdomain: account).first
      q = q.where("account_id = ?", a.id) if a
    end

    if device_ui.present?
      d = MobileDevice.where(unique_identifier: device_ui).first
      q = q.where("mobile_device_id = ?", d.id) if d
    end

    q
  end

end