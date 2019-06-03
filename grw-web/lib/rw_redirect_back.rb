module RwRedirectBack

  module Common

    def redirect_back_url
      pop_url
    end

    def redirect_back_push(url = nil)
      url = request.original_url if url.nil?
      { "return_to_url" => [ url ].concat(back_url) }
    end

    def redirect_back_params
      { "return_to_url" => back_url }
    end

    def redirect_back_start
      { "return_to_url" => [ "/" ] }
    end

    private

    def back_url
      list = params["return_to_url"]
      if list.nil? || list.empty?
        if request.headers["Turbolinks-Referrer"].present?
          [ request.headers["Turbolinks-Referrer"] ]
        elsif request.referer.present?
          [ request.referer ]
        else
          [ "/" ]
        end
      else
        list
      end
    end

    def pop_url
      list = back_url
      if list.size == 1
        list[0]
      else
        merge_param(list[0], { "return_to_url" => list[1..-1] })
      end
    end

    def merge_param(url, opt)
      parsed = URI.parse(url)
      new_params = HashWithIndifferentAccess.new(Rack::Utils.parse_nested_query(parsed.query)).merge(opt)
      parsed.query = nil
      parsed.to_s + "?" + new_params.to_param
    end

  end

  module Controller
    def rw_redirect_back
      respond_to do |format|
        format.html { redirect_to pop_url }
        format.js { render :js => "document.location.href = '#{ url_for(pop_url) }';" }
      end
    end
  end

  module View
    def rw_hidden_back_url
      back_url.map do |u|
        hidden_field_tag "return_to_url[]", u
      end.join("\n").html_safe
    end
  end

end

class ActionController::Base
  include RwRedirectBack::Common
  include RwRedirectBack::Controller
end

class ActionView::Base
  include RwRedirectBack::Common
  include RwRedirectBack::View
end
