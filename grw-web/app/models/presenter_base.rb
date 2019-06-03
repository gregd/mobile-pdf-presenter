class PresenterBase

  def self.set_view_context(vc)
    RequestStore.store[:current_view_context] = vc
  end

  def self.view_context
    RequestStore.store[:current_view_context]
  end

end