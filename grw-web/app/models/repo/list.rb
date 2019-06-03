module Repo

  class List

    def self.default_repo
      "main".freeze
    end

    def self.known_repo?(name)
      ["main"].include?(name)
    end

  end

end