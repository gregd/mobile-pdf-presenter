module AddressesHelper

  def rw_address_short(addr)
    s = "#{addr.city}, #{addr.street} #{addr.house_nr}"
    s << "/#{addr.flat_nr}" if addr.flat_nr
    s.html_safe
  end

  def rw_address_long(addr)
    s = ''
    s << "#{addr.country}, " if addr.country != 'Polska'
    s << "#{addr.zipcode} #{addr.city}, #{addr.street} #{addr.house_nr}"
    s << "/#{addr.flat_nr}" if addr.flat_nr
    s << " <span class='text-size-small'>#{addr.comments}</span>" if addr.comments
    s.html_safe
  end

end
