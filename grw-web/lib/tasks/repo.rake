namespace :rw do
  namespace :repo do

    desc "Recreate TrackerFile and TrackerItem records."
    task :fix_ids => :environment do
      Account.all.each do |account|
        Account.set_current(account)

        repo ||= begin
          user_id = account.users.first.id
          user = Repo::UserAdmin.new(user_id)
          Repo::Git.new(account.id, Repo::List.default_repo, user)
        end

        list = repo.list(full: true, sort: :dirs_first, meta_info: true)

        TrackerFile.transaction do
          list.each do |item|
            info = item.meta_info
            tracking_id = info[:tracking_id]
            next unless tracking_id

            tf = TrackerFile.where(id: tracking_id).first
            next if tf

            puts "No TrackerFile for: #{item.path}"

            TrackerFile.get_tracking_id(
              repo.repo_name,
              info[:hash],
              item.path,
              info[:mime_type],
              { pages: info[:pages], seconds: info[:seconds] },
              tracking_id)
          end

          [TrackerFile, TrackerItem].each do |klass|
            klass.connection.reset_pk_sequence!(klass.table_name)
          end
        end
      end
    end

  end
end

