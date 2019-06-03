module Repo

  class UserMobile < Repo::User

    def initialize(user_id)
      super(user_id)
    end

    def filter_items(list)
      list
    end

  end

end