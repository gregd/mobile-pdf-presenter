module Repo

  class ContentVideo

    def process(info, abs_dir, abs_file)
      h = av_probe(abs_file)
      info[:seconds] = h["seconds"] if h["seconds"].present?

      make_cover(abs_dir, abs_file)
    end

    private

    def av_probe(abs_file)
      s = `avprobe '#{abs_file}' 2>&1`
      result = {}
      if s =~ /duration: (\d\d):(\d\d):(\d\d).(\d\d)/i
        hundredths = $4.to_i
        seconds = $1.to_i * 3600 + $2.to_i * 60 + $3.to_i + (hundredths > 50 ? 1 : 0)
        result["seconds"] = seconds
      end
      result
    end

    def make_cover(abs_dir, abs_file)
      t = File.join(abs_dir, "cover.jpeg")
      `avconv -i '#{abs_file}' -vframes 1 '#{t}'`
    end

  end

end