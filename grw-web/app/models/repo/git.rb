module Repo

  class Git
    GIT_KEEP = ".gitkeep".freeze

    attr_reader :repo_name

    def initialize(account_id, repo_name, user)
      @account_id = account_id
      @repo_name = repo_name
      @user      = user
      @path      = Path.new(account_id: account_id, repo_name: repo_name)
    end

    def list(path: nil, rev: "HEAD", full: false, sort: nil, meta_info: false)
      result = ls_tree(path: path, rev: rev, full: full)
      result = @user.filter_items(result)
      if sort == :dirs_first
        result = result.sort_by {|p| p.dir? ? "\t#{p.basename}" : p.basename }
      end
      if meta_info
        result.each do |i|
          meta_dir = @path.abs_meta_dir(i.path)
          rel_dir = @path.rel_meta_dir(i.path)
          i.load_meta_info(meta_dir)
          i.find_cover_picture(meta_dir, rel_dir)
        end
      end
      result
    end

    def dirs(path: nil)
      result = ls_tree(path: path, dir_only: true, full: true)
      @user.filter_items(result)
    end

    def mkdir(path, dir_name)
      return "Nazwa katalogu nie może być pusta lub zawierać tylko znaki specjalne." unless dir_name

      abs_dir   = @path.abs_path(path, dir_name)
      rel_file  = @path.rel_path(path, dir_name, GIT_KEEP)
      abs_file  = @path.abs_path(path, dir_name, GIT_KEEP)

      if File.exists?(abs_dir)
        return "Katalog lub plik o podanej nazwie już istnieje."
      end

      # GIT doesn't track directories so have to create a file
      FileUtils.mkdir_p(abs_dir)
      FileUtils.touch(abs_file)

      cmd = add_commit_cmd(rel_file, "Dodany katalog '#{dir_name}'")
      run_system(cmd)
      return nil

    rescue
      rollback
      raise
    end

    def upload(path, tempfile_path, original_filename)
      base_name = File.basename(original_filename)
      abs_path  = @path.abs_path(path, base_name)
      rel_path  = @path.rel_path(path, base_name)
      meta_dir  = @path.abs_meta_dir(rel_path)

      new_version = File.exists?(abs_path)

      if File.directory?(abs_path)
        return "Nie można nadpisać katalogu plikiem."
      end
      if File.directory?(meta_dir)
        FileUtils.rm_rf(meta_dir)
      end

      FileUtils.cp(tempfile_path, abs_path)
      MetaInfo.create(repo_name, meta_dir, abs_path, rel_path, hash_object(abs_path))

      message = new_version ? "Aktualizacja pliku '#{base_name}'" : "Dodany plik '#{base_name}'"
      cmd = add_commit_cmd(nil, message)
      run_system(cmd)
      return nil

    rescue
      rollback
      raise
    end

    def download(path)
      abs_path = @path.abs_path(path)
      if File.readable?(abs_path) && (! File.directory?(abs_path))
        meta_type = MimeType.detect_mime(abs_path)
        size = File.new(abs_path).size
        return abs_path, meta_type, size
      else
        return nil, nil, nil
      end
    end

    def tempfile_for(rev, path)
      rev_path = Repo::Path.new(account_id: @account_id, repo_name: @repo_name, tmp_rev: rev)
      unless File.directory?(rev_path.repo_path)
        unless File.directory?(rev_path.repo_path_parent)
          FileUtils.mkdir_p(rev_path.repo_path_parent)
        end
        cmd = clone_cmd(rev_path.repo_path_parent, rev)
        run_system(cmd)
      end

      abs_path = rev_path.abs_path(path)
      unless File.readable?(abs_path) && (! File.directory?(abs_path))
        raise "File not found: #{path}"
      end

      meta_type = MimeType.detect_mime(abs_path)
      size = File.new(abs_path).size
      return abs_path, meta_type, size
    end

    def rename(path, new_name)
      old_basename = File.basename(path)
      abs_path     = @path.abs_path(path)
      meta_dir     = @path.abs_meta_dir(path)

      unless File.exist?(abs_path)
        return "Plik / katalog o takiej nazwie już nie istnieje. Ktoś inny musiał go zmienić."
      end

      unless File.directory?(abs_path)
        new_name = new_name + File.extname(abs_path)
      end
      new_path = @path.rename(path, new_name)

      if new_path == path
        return "Nazwa pliku pozostała niezmieniona."
      end
      if File.exists?(@path.abs_path(new_path))
        return "Plik o docelowej nazwie już istnieje."
      end

      renames = [[path, new_path]]

      if File.exist?(meta_dir)
        Repo::MetaInfo.update(repo_name, meta_dir, new_path)
        renames << [@path.rel_meta_dir(path), @path.rel_meta_dir(new_path)]
      end

      cmd = mv_commit_cmd(renames, "Zmiana nazwy pliku/katalogu z '#{old_basename}' na '#{new_name}'")
      run_system(cmd)
      return nil

    rescue
      rollback
      raise
    end

    def remove(path)
      abs_path = @path.abs_path(path)

      unless File.exist?(abs_path)
        return "Plik o podanej nazwie nie istnieje."
      end

      paths = [path]
      if File.exist?(@path.abs_meta_dir(path))
        paths << @path.rel_meta_dir(path)
      end
      cmd = rm_commit_cmd(paths, "Usunięcie pliku/katalogu '#{path}'")
      run_system(cmd)
      return nil

    rescue
      rollback
      raise
    end

    def move(path, new_dir)
      new_path = @path.move(path, new_dir)
      meta_dir = @path.abs_meta_dir(path)

      if new_path == path
        return "Nie wybrałeś nowego katalogu."
      end
      if File.exists?(@path.abs_path(new_path))
        return "W docelowym katalogu już istnieje plik o takiej nazwie."
      end

      renames = [[path, new_path]]
      if File.exist?(@path.abs_meta_dir(path))
        Repo::MetaInfo.update(repo_name, meta_dir, new_path)
        renames << [@path.rel_meta_dir(path), @path.rel_meta_dir(new_path)]
      end

      cmd = mv_commit_cmd(renames, "Przeniesienie z '#{path}' do '#{new_path}'")
      run_system(cmd)
      return nil

    rescue
      rollback
      raise
    end

    def head_rev
      run_system("cd #{@path.repo_path}; git rev-parse --verify HEAD").strip
    end

    def modified(rev = 'HEAD')
      d = run_system("cd #{@path.repo_path}; git log -1 --format=%cd #{rev}").strip
      Time.parse(d)
    end

    def self.create_empty(account_id)
      path = Path.new(account_id: account_id, repo_name: Repo::List.default_repo)

      if File.directory?(path.repo_path)
        Rails.logger.info "REPO: git repo exists for account #{account_id}"
        return
      end

      Rails.logger.info "REPO: new repo for account #{account_id}"
      FileUtils.makedirs(path.repo_path)
      `cd '#{path.repo_path}'; git init; touch #{GIT_KEEP}; git add .; git commit -m 'Start' --author='0 <admin@example.com>'`
    end

    def self.remove_repo(account_id)
      path = Path.new(account_id: account_id, repo_name: Repo::List.default_repo)

      unless File.directory?(path.repo_path)
        Rails.logger.warn "REPO: git repo already removed for account #{account_id}"
        return
      end

      Rails.logger.info "REPO: remove repo for account #{account_id}"
      FileUtils.rm_rf(path.repo_path)
    end

    private

    def hash_object(path)
      run_system("cd #{@path.repo_path}; git hash-object '#{path}'").strip
    end

    def clone_cmd(tmp_dir, rev)
      "cd '#{tmp_dir}'; git clone --shared --no-checkout '#{@path.repo_path}' #{rev}; cd #{rev}; git checkout --detach #{rev} 2>&1"
    end

    def add_commit_cmd(local, message)
      "cd #{@path.repo_path}; git add '#{local ? local : '.'}' && git commit -m \"#{message}\" --author='#{@user.email}' 2>&1"
    end

    def mv_commit_cmd(renames, message)
      # commit -a because the metafile is also changed, but git mv doesn't add it to the index
      s = renames.map {|r| "git mv -k '#{r[0]}' '#{r[1]}'" }.join(" && ")
      "cd #{@path.repo_path}; #{s} && git commit -a -m \"#{message}\" --author='#{@user.email}' 2>&1"
    end

    def rm_commit_cmd(paths, message)
      files = paths.map {|p| "'#{p}'" }.join(" ")
      "cd #{@path.repo_path}; git rm -r #{files} && git commit -m \"#{message}\" --author='#{@user.email}' 2>&1"
    end

    def ls_tree(path: nil, rev: "HEAD", full: false, dir_only: false)
      path = "#{path}/" if path.present? && path[-1] != "/"
      path = "'#{path}'" if path.present?
      cmd = "cd #{@path.repo_path}; git ls-tree -zl#{full ? 'r' : ''}#{dir_only ? 'd' : '' } #{rev} #{path} 2>&1"
      output = run_system(cmd)

      unless $?.success?
        raise "Failed git ls-tree: #{$?.exitstatus}"
      end

      output.split("\0").map do |line|
        a, path = line.split("\t", 2)
        mode, type, hash, size = a.split(" ")
        RepoItem.new(path.strip, mode, type, hash, size)
      end
    end

    def run_system(cmd)
      Rails.logger.debug("REPO: #{cmd}")
      output = `#{cmd}`
      unless $?.success?
        raise "Failed git: #{output}"
      end
      output
    end

    def rollback
      Rails.logger.debug("REPO: rollback")
      `cd #{@path.repo_path}; git reset --hard HEAD; git clean -f`
    end

  end

end
