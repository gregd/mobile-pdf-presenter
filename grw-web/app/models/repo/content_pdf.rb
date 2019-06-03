module Repo

  class ContentPdf

    def process(info, abs_dir, abs_file)
      h = pdf_info(abs_file)
      info[:pages]        = h["pages"].to_i   if h["pages"].present?
      info[:title]        = h["title"]        if h["title"].present?
      info[:description]  = h["subject"]      if h["subject"].present?

      make_cover(abs_dir, abs_file)
    end

    private

    def pdf_info(abs_file)
      `pdfinfo '#{abs_file}'`.each_line.map do |r|
        key, val = r.split(/:\s+/)
        [key.downcase, val.strip]
      end.to_h
    end

    def make_cover(abs_dir, abs_file)
      t = File.join(abs_dir, "cover.png")
      `gs -q -dNOPAUSE -dBATCH -sDEVICE=pngalpha -r50 -dLastPage=1 -sOutputFile='#{t}' '#{abs_file}'`
    end

  end

end