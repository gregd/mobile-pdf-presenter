module Repo

  class MetaInfo
    FILE_NAME = "meta-info.json".freeze

    def initialize
      @info = {}
    end

    def set_info(info)
      @info = info
    end

    def set_common(rel_path, hash, tracking_id)
      @info[:hash]        = hash
      @info[:rel_path]    = rel_path
      @info[:tracking_id] = tracking_id
    end

    def update_path(rel_path, tracking_id)
      @info[:rel_path] = rel_path
      @info[:tracking_id] = tracking_id
    end

    def process(abs_dir, abs_file)
      if File.directory?(abs_file)
        # cover?, number of user visible files?
      else
        size = File.new(abs_file).size
        @info[:file_size] = size
        @info[:mime_type] = MimeType.detect_mime(abs_file)
        mime_type.handler.process(@info, abs_dir, abs_file)
      end
    end

    def mime_type
      @mime_type ||= Repo::MimeType.new(@info[:mime_type])
    end

    def [](key)
      @info[key]
    end

    def to_json
      JSON.generate(@info, { object_nl: "\n" }) + "\n"
    end

    def save_to(dir)
      meta_file = File.join(dir, FILE_NAME)
      File.write(meta_file, to_json)
    end

    def self.load_from(abs_dir)
      meta_file = File.join(abs_dir, FILE_NAME)
      info = new
      info.set_info(JSON.parse(IO.read(meta_file), symbolize_names: true))
      info
    end

    def self.create(repo_name, abs_dir, abs_file, rel_file, hash)
      FileUtils.mkpath(abs_dir)
      info = new
      info.process(abs_dir, abs_file)
      tracking_id = TrackerFile.get_tracking_id(repo_name, hash, rel_file, info[:mime_type],
                                                { pages: info[:pages], seconds: info[:seconds] }, nil)
      info.set_common(rel_file, hash, tracking_id)
      info.save_to(abs_dir)
      info
    end

    def self.update(repo_name, abs_dir, new_rel_path)
      info = load_from(abs_dir)
      tracking_id = TrackerFile.get_tracking_id(repo_name, info[:hash], new_rel_path, info[:mime_type],
                                                { pages: info[:pages], seconds: info[:seconds] }, nil)
      info.update_path(new_rel_path, tracking_id)
      info.save_to(abs_dir)
      info
    end

  end

end
