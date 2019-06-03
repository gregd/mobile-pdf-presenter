module Repo

  class UserAdmin < Repo::User

    def initialize(user_id)
      super(user_id)
    end

    def email
      "#{@user_id} <#{@user_id}@foo.bar>"
    end

    def filter_items(list)
      list.reject {|item| Path.hidden?(item) || Path.meta_dir?(item) }
    end

  end

end