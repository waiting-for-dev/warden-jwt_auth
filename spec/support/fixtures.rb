# frozen_string_literal: true

module Fixtures
  # An user record
  class User
    def jwt_subject
      1
    end

    def jwt_payload
      { 'foo' => 'bar' }
    end
  end

  # User repository
  class UserRepo
    def self.find_for_jwt_authentication(_sub)
      User.new
    end
  end

  # A dummy revocation strategy which keeps the state in its instances
  class RevocationStrategy
    attr_reader :revoked

    def initialize
      @revoked = []
    end

    def revoke(payload)
      revoked << payload['jti']
    end

    def revoked?(payload, _user)
      revoked.member?(payload['jti'])
    end
  end
end
