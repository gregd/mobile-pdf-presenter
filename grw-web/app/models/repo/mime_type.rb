module Repo

  class MimeType

    def initialize(type)
      @type = type
    end

    def pdf?
      @type == "application/pdf"
    end

    def video?
      @type == "video/mp4"
    end

    def supported?
      pdf? || video?
    end

    def handler
      @handler ||= begin
        if pdf?
          Repo::ContentPdf.new
        elsif video?
          Repo::ContentVideo.new
        else
          Repo::ContentUnknown.new
        end
      end
    end

    def self.detect_mime(abs_path)
      type = `file -b --mime '#{abs_path}'`
      if type.nil? || type.match(/\(.*?\)/)
        # sensible default
        type = "application/octet-stream"
      end
      type.split(/[:;\s]+/)[0]
    end

    def self.new_for_file(abs_path)
      new(detect_mime(abs_path))
    end

  end

end
