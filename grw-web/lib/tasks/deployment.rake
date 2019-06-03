namespace :rw do

  namespace :menus do
    desc "Save menu items config to yml files."
    task :save => :environment do
      Service::AppMenu.save_config($stdout)
    end

    desc "Load menu items config from yml files."
    task :load => :environment do
      Service::AppMenu.load_config($stdout)
    end

    desc "Create Menu Items for new controllers actions."
    task :create => :environment do
      Service::AppMenu.create_items($stdout)
    end

  end
end
