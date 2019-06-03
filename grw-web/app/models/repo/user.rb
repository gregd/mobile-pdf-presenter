module Repo

  class User

    def initialize(user_id)
      @user_id = user_id
    end

    def email
      raise "Only admin user can modify file repo"
    end

    def filter_items(list)
      []
    end

  end

end
