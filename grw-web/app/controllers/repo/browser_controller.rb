class Repo::BrowserController < ClientController
  include PermControl
  before_action :load_dictionaries

  def index
    @path = path_param
    @basename = @path.present? ? File.basename(@path) : nil
    @list = repo.list(path: @path, sort: :dirs_first, meta_info: true)
    @dirs = repo.dirs.map {|i| i.path }.prepend('')
  end

  def mkdir
    path = path_param
    dir_name = @sanitizer.filename(params[:dir_name])

    result = repo.mkdir(path, dir_name)
    flash[:error] = result if result

    redirect_to repo_browser_index_path(path: path)
  end

  def upload
    path = path_param
    tempfile = params[:file]

    unless tempfile
      flash[:error] = "Wybierz plik a następnie kliknij przycisk 'Wyślij plik'"
      rw_redirect_back
      return
    end

    mt = Repo::MimeType.new_for_file(tempfile.path)
    unless mt.supported?
      flash[:error] = "Ten typ pliku nie jest obsługiwany. Nie wyświetli się poprawnie na tablecie. Uwaga: prezentacje PowerPoint należy zapisać jako PDF."
      rw_redirect_back
      return
    end

    upload_name = @sanitizer.filename(tempfile.original_filename)
    result = repo.upload(path, tempfile.path, upload_name)
    flash[:error] = result if result

    redirect_to repo_browser_index_path(path: path)
  end

  def download
    path = @sanitizer.path(params[:path], true)
    file_name, mime_type, size = repo.download(path)
    if file_name
      response.headers["Content-Length"] = size.to_s
      send_file(
        file_name,
        { filename: File.basename(file_name),
          type: mime_type,
          disposition: "inline" })
    else
      render :plain => "File not found"
    end
  end

  def rename
    path = path_param
    new_name = @sanitizer.filename(params[:new_name])

    result = repo.rename(path, new_name)
    flash[:error] = result if result

    redirect_to repo_browser_index_path(path: File.dirname(path))
  end

  def remove
    path = path_param

    result = repo.remove(path)
    flash[:error] = result if result

    redirect_to repo_browser_index_path(path: File.dirname(path))
  end

  def move
    path = path_param
    new_dir = @sanitizer.path(params[:new_dir])

    result = repo.move(path, new_dir)
    flash[:error] = result if result

    redirect_to repo_browser_index_path(path: new_dir)
  end

  private

  def load_dictionaries
    @sanitizer = Repo::Sanitizer.new
  end

  def path_param
    @sanitizer.path(params[:path])
  end

  def repo
    @repo ||= begin
      user = Repo::UserAdmin.new(current_user.id)
      Repo::Git.new(Account.current.id, Repo::List.default_repo, user)
    end
  end

end
