require 'spreadsheet'

require 'excelto/action_controller'
require 'excelto/template_handler'

Mime::Type.register "application/vnd.ms-excel", :xls
ActionView::Template.register_template_handler :excel, Excelto::TemplateHandler

#ActionView::Template.exempt_from_layout :excel
