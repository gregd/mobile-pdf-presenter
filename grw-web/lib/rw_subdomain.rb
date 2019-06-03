module RwSubdomain

  class Www
    def self.matches?(request)
      request.subdomain.present? && request.subdomain.downcase.start_with?("www")
    end
  end

  class Admin
    def self.matches?(request)
      request.subdomain.present? && request.subdomain.downcase.start_with?("admin")
    end
  end

  class Client
    def self.matches?(request)
      return true if Rails.env.development? # allow to test app without dns in local network, default account is set in ClientController

      return false unless request.subdomain.present?
      sd = request.subdomain.downcase
      ! (sd.start_with?("www") || sd.start_with?("admin") || sd.start_with?("utils"))
    end
  end

  class Android
    def self.matches?(request)
      return false unless request.fullpath.start_with?("/api")
      return true if Rails.env.development? # allow to set default subdomain in dev mode, mobile client has to set dev_subdomain parameter

      return false unless request.subdomain.present?
      sd = request.subdomain.downcase
      ! (sd.start_with?("www") || sd.start_with?("admin") || sd.start_with?("utils"))
    end
  end

end
