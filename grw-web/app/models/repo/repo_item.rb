module Repo

  class RepoItem
    COVER_FILE_NAMES = ["cover.png", "cover.jpeg", "cover.jpg"].freeze

    attr_reader :path, :mode, :type, :hash, :size, :meta_info

    def initialize(path, mode, type, hash, size)
      @path = path
      @mode = mode
      @type = type
      @hash = hash
      @size = size.to_i
    end

    def dir?
      @type == "tree"
    end

    def basename
      @basename ||= File.basename(@path)
    end

    def name_without_ext
      @name_without_ext ||= File.basename(@path, ".*")
    end

    def name_for_rename
      dir? ? basename : name_without_ext
    end

    def dirname
      @dirname ||= File.dirname(@path)
    end

    def load_meta_info(meta_dir)
      if File.exist?(meta_dir)
        @meta_dir = meta_dir
        @meta_info = Repo::MetaInfo.load_from(@meta_dir)
      else
        @meta_dir = nil
        @meta_info = Repo::MetaInfo.new
      end
    end

    def rel_cover_picture
      @rel_cover_picture
    end

    def find_cover_picture(abs_dir, rel_dir)
      @rel_cover_picture = nil
      COVER_FILE_NAMES.each do |img|
        n = File.join(abs_dir, img)
        if File.readable?(n)
          @rel_cover_picture = File.join(rel_dir, img)
          break
        end
      end
    end

  end

end
