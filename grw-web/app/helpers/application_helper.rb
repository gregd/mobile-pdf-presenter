module ApplicationHelper

  def app_body_classes
    s = ""
    s << " sidebar-xs" if current_web_option && ! current_web_option.sidebar_wide
    s
  end

  def app_error_messages(ob)
    if ob.errors.any?
      render "shared/app_error_messages", :ob => ob
    end
  end

  def app_account_name
    a = Account.current
    a ? a.company : nil
  end

  def rwf_field(form, type, *args)
    if args.size <= 1
      # w przypadku podawania opcji trzeba ręcznie dodać klasę form-control
      args << { class: "form-control" }
    end
    content_tag(:div, class: "form-group") do
      form.label(args[0], class: "control-label") +
        form.send(type, *args)
    end
  end

  def rwf_text_field(form, method, options = {})
    required = !! options[:rw_required]
    options = options.merge(class: "#{options[:class]} form-control")

    content_tag(:div, class: "form-group #{required ? 'rwc-RequiredField' : ''}") do
      form.label(method, class: "control-label") +
        form.text_field(method, options)
    end
  end

  def rwf_check_box(form, method)
    content_tag(:div, class: "form-group") do
      content_tag(:div, class: "checkbox") do
        content_tag(:label, class: "control-label") do
          form.check_box(method) +
            form.object.class.human_attribute_name(method)
        end
      end
    end
  end

  def rwf_select(form, method, choices = nil, options = {}, html_options = {}, &block)
    required = !! options[:rw_required]
    html_options = html_options.merge(class: "#{html_options[:class]} form-control")

    content_tag(:div, class: "form-group #{required ? 'rwc-RequiredField' : ''}") do
      form.label(method, class: "control-label") +
        form.select(method, choices, options, html_options, &block)
    end
  end

  def rw_link_to_google_maps(lat, lng, name = nil)
    name = "#{lat},#{lng}" if name.nil?
    "<a href='http://maps.google.pl?q=#{lat},#{lng}' target='_blank'>#{name}</a>".html_safe
  end

  def rw_number_to_phone(nr)
    if nr.starts_with?("48")
      nr.gsub(/(\d{2})(\d{3})(\d{2})(\d{2})(\d{2}$)/,"\\2 \\3 \\4 \\5")
    else
      nr
    end
  end

  def rw_pagination_summary(results)
    content_tag :span,
                "Wyniki #{((results.current_page-1)*results.per_page)+1}-#{((results.current_page-1)*results.per_page+results.size)} z #{results.total_entries}",
    class: "rwc-SearchResults-total"
  end

end
