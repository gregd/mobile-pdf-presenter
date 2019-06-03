module Repo

  class Path
    META_DIR_PREFIX = "__".freeze
    UNIX_DOT = ".".freeze

    def initialize(account_id:, repo_name: nil, tmp_rev: nil)
      @account_id = account_id
      @repo_name = repo_name
      @tmp_rev = tmp_rev
    end

    def repo_path
      @repo_path ||= begin
        if @tmp_rev
          File.join(Rails.root, "tmp", "cache-repo", "a#{@account_id}", "#{@repo_name}", @tmp_rev)
        else
          File.join(Rails.root, "data", "repos", "a#{@account_id}", @repo_name)
        end
      end
    end

    def repo_path_parent
      File.dirname(repo_path)
    end

    def abs_path(path, *list)
      validate_rel_path(path)
      compact_join(repo_path, path, list)
    end

    def rel_path(path, *list)
      validate_rel_path(path)
      compact_join(path, list)
    end

    def abs_meta_dir(path)
      validate_rel_path(path)
      dir = clean_dirname(path)
      base_name = File.basename(path)
      compact_join(repo_path, dir, "#{META_DIR_PREFIX}#{base_name}")
    end

    def rel_meta_dir(path)
      validate_rel_path(path)
      dir = clean_dirname(path)
      base_name = File.basename(path)
      compact_join(dir, "#{META_DIR_PREFIX}#{base_name}")
    end

    def rename(path, new_name)
      validate_rel_path(path)
      compact_join(clean_dirname(path), new_name)
    end

    def move(path, new_dir)
      validate_rel_path(path)
      basename = File.basename(path)
      compact_join(new_dir, basename)
    end

    def self.meta_dir?(path)
      path.basename.start_with?(META_DIR_PREFIX)
    end

    def self.hidden?(path)
      path.basename.start_with?(UNIX_DOT)
    end

    private

    def validate_rel_path(path)
      raise "Required rel path but got #{path}" if path && path.start_with?("/")
    end

    def compact_join(*list)
      File.join(list.map {|part| part.present? ? part : nil }.compact)
    end

    def clean_dirname(path)
      return nil if path.blank?
      dir = File.dirname(path)
      dir == "." ? nil : dir
    end

  end

end