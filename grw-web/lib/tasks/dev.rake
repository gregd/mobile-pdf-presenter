namespace :rw do
  namespace :dev do

    desc "Recreate db"
    task :recreate_db do
      puts `rake db:drop`
      puts `rake db:create`
      puts `rake db:migrate`
      puts `rake rw:menus:load`
      puts `rake db:seed`
    end

    desc "Rebuild zipcodes using Poczta Polska txt file."
    task :load_zipcodes => :environment do
      CityStreet::Service.reload_txt_file($stdout)
    end

    desc "Build geo partitions."
    task :build_geo_partitions => :environment do
      GeoPartition::AsStart.build_partitions($stdout)
    end

  end
end
