class Service::AppMenu

  def self.create_items(sio)
    ActiveRecord::Base.transaction do
      arr = []
      arr.concat(controllers_methods)
      arr.concat(special_actions)
      AppMenuItem::AsEdit.create_items(sio, arr)
      AppPermission::AsEdit.update_matrix(sio)
    end
  end

  def self.save_config(sio)
    config_klasses.each do |klass|
      save_to_file(klass)
    end
    sio.puts "Menus saved"
  end

  def self.load_config(sio)
    ActiveRecord::Base.transaction do
      config_klasses.each do |klass|
        load_from_file(klass)
      end
      sio.puts "Menus loaded"
      AppPermission::AsEdit.update_matrix(sio)
    end
  end

  private

  def self.config_klasses
    [ AccountPlan, AppModule, AppMenuItem, AppActionGroup, AppStatGroup, AppRoleSet, AppRole, AppPermission ].freeze
  end

  def self.dir
    @storage_dir ||= File.join(Rails.root, 'db', 'access_control').freeze
  end

  def self.special_actions
    YAML.load_file(File.join(dir, "partial_actions.yml")).each {|h| h.symbolize_keys! }
  end

  def self.file_name(name)
    File.expand_path(File.join(dir, name + '.yml'), Rails.root)
  end

  def self.save_to_file(klass)
    f = File.new(file_name(klass.table_name), "w+")
    dump = klass.all.order(klass.primary_key).map {|r| r.attributes }.to_yaml
    f.puts(dump)
    f.close
  end

  def self.load_from_file(klass)
    klass.delete_all

    raw_data = File.read(file_name(klass.table_name))
    YAML::load(raw_data).each do |record|
      r = klass.new(record)
      r.save!(:validate => false)
    end

    ActiveRecord::Base.connection.reset_pk_sequence!(klass.table_name)
  end

  def self.controllers_methods
    arr = []
    menu_klasses.each do |c|
      c.new.public_methods(false).sort.each do |method|
        name = method.to_s
        next if name =~ /^_one_time_conditions_valid/

        arr << { controller: c.controller_path, action: name }
      end
    end

    arr
  end

  def self.menu_klasses
    prefix_chars = File.join(Rails.root, "app", "controllers").size + 1

    Dir[Rails.root.join('app/controllers/**/*_controller.rb')].map do |path|
      controller_file = path[prefix_chars .. -4]
      klass = controller_file.camelize.constantize
      klass.perm_control? ? klass : nil
    end.compact
  end

end
