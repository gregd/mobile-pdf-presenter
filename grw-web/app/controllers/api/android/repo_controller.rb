class Api::Android::RepoController < Api::Android::BaseController

  def index
    client_ver = mobile_client_version
    client_rev = param_repo_rev
    head_rev = repo.head_rev

    if params[:repo] && params[:stats] && params[:current]
      MobileStatsLog.create!(
        :mobile_device_id         => @mobile_device.id,
        :head_rev                 => head_rev,
        :repo_name                => params[:repo][:name],
        :client_rev               => params[:repo][:rev],
        :current_rev              => params[:current][:rev],
        :missing_count            => params[:current][:missing_count],
        :missing_size             => params[:current][:missing_size],
        :unlinked_count           => params[:current][:unlinked_count],
        :total_mem                => params[:stats][:total_mem],
        :internal_available_bytes => params[:stats][:internal_available_bytes],
        :internal_total_bytes     => params[:stats][:internal_total_bytes],
        :external_available_bytes => params[:stats][:external_available_bytes],
        :external_total_bytes     => params[:stats][:external_total_bytes])
    end

    result = { result:    "success",
               repo_name: repo.repo_name,
               hash:      head_rev }

    if client_rev && (client_rev == head_rev) && ! (@mobile_device.flag_repo_reset? || @mobile_device.flag_repo_recover?)
      MobileLog.event(@mobile_device, "info", "repo", "current #{client_rev}", params.dig("device", "time"))
      result[:state] = "current"
      render :json => result
      return
    end

    if @mobile_device.flag_repo_reset?
      MobileLog.event(@mobile_device, "info", "repo", "reset", params.dig("device", "time"))
      @mobile_device.flag_repo_reset = false
      @mobile_device.save!
      result[:repo_reset] = true

    elsif @mobile_device.flag_repo_recover?
      MobileLog.event(@mobile_device, "info", "repo", "recover", params.dig("device", "time"))
      @mobile_device.flag_repo_recover = false
      @mobile_device.save!
      result[:repo_recover] = true
    end

    items = repo.list(rev: head_rev, full: true).map do |i|
      { path: i.path,
        type: i.type,
        hash: i.hash,
        size: i.size }
    end

    result = result.merge(
      { state:         "new",
        modified_at:   repo.modified(head_rev).to_s(:iso8601),
        items_count:   items.size,
        items:         items })

    MobileLog.event(@mobile_device, "info", "repo", "new #{head_rev} #{items.size}", params.dig("device", "time"))
    render :json => result
  end

  def download
    client_rev = param_repo_rev
    path = param_repo_path(true)

    if client_rev.nil? || path.nil?
      raise "Incorrect params"
    end

    tmp_name, mime_type, size = repo.tempfile_for(client_rev, path)

    response.headers["Content-Length"] = size.to_s
    send_file(
      tmp_name,
      { filename: path,
        mime_type: mime_type })
  end

  private

  def load_dictionaries
    @sanitizer = Repo::Sanitizer.new
  end

  def repo
    @repo ||= begin
      user = Repo::UserMobile.new(current_user.id)
      repo_name = param_repo_name
      raise "Unknown repo name" unless repo_name.present?
      Repo::Git.new(Account.current.id, repo_name, user)
    end
  end

  def param_repo_name
    if params[:repo] && params[:repo][:name]
      name = params[:repo][:name]
      Repo::List.known_repo?(name) ? name : nil
    else
      Repo::List.default_repo
    end
  end

  def param_repo_rev
    if params[:repo] && params[:repo][:rev]
      @sanitizer.git_rev(params[:repo][:rev])
    else
      nil
    end
  end

  def param_repo_path(download = false)
    if params[:repo] && params[:repo][:path]
      @sanitizer.path(params[:repo][:path], download)
    else
      nil
    end
  end

end
