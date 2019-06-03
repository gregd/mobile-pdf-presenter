module Excelto
  module TemplateHandler

    def self.call(template)
      <<-RUBYCODE
        controller.response.content_type ||= 'application/vnd.ms-excel'
        _excelto_options = controller.send(:compute_excelto_options) || {}
        controller.headers['Content-Disposition'] =
          [_excelto_options[:inline] ? 'inline' : 'attachment',
           _excelto_options[:filename] ? 'filename=' + _excelto_options[:filename].to_s : nil].compact.join(';')
        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet::Workbook.new
        #{template.source}
        book_sio = StringIO.new; book.write(book_sio); book_sio.string.force_encoding('BINARY')
      RUBYCODE
    end
    
  end
end

