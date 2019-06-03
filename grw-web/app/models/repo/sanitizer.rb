module Repo

  class Sanitizer

    def initialize
    end

    # 127 chars max, 256 max chars on Android (127 unicode chars)
    # First step, whitelist allowed characters. Next steps handle
    # spaces, '..' and '__'.
    def filename(p, download = false)
      return nil if p.nil?
      p = p.gsub(/[^\x20a-zA-Z0-9ąĄćĆęĘłŁńŃóÓśŚźŹżŻ\._\-]/, '')
      p = p.gsub(/\s+/, ' ').strip
      p = p.gsub(/_+/, '_') unless download
      p = p.gsub(/\s+\./, '.')
      p = p.gsub(/\.+/, '.')
      p = p.gsub(/\A\./, '')
      p = p[0, 127]
      p
    end

    def path(p, download = false)
      return nil if p.nil?
      p = p.gsub(/\/+/, '/').
        split('/').
        map {|i| filename(i, download) }.
        map {|i| i =~ /^\.+$/ ? nil : i }.
        compact.
        join('/').
        gsub(/\/+/, '/')
      p == '' ? nil : p
    end

    def git_rev(r)
      return nil if r.nil? || r.size != 40
      r =~ /^[a-zA-Z0-9]+$/ ? r : nil
    end

  end

end