# frozen_string_literal: true

require 'singleton'

module Fixtures
  # An user record
  class User
    include Singleton

    def jwt_subject
      '1'
    end

    def jwt_payload
      { 'foo' => 'bar' }
    end

    def on_jwt_dispatch(_token, _payload)
      # Does something
    end
  end

  # User repository
  class UserRepo
    def self.find_for_jwt_authentication(_sub)
      User.instance
    end
  end

  # User repository that mimics returning a nil user (probably a user that has
  # been deleted)
  class NilUserRepo
    def self.find_for_jwt_authentication(_sub)
      nil
    end
  end
end
