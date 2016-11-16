# frozen_string_literal: true

require 'jwt'

module Warden
  module JWTAuth
    # Encode/decode a user
    class UserCoder
      def self.encode(user, config)
        new.send(:encode, user, config)
      end

      def self.decode(user, scope, config)
        new.send(:decode, user, scope, config)
      end

      private

      # :reek:UtilityFunction
      def encode(user, config)
        sub = user.jwt_subject
        payload = { sub: sub }
        TokenCoder.encode(payload, config)
      end

      # :reek:UtilityFunction
      def decode(token, scope, config)
        payload = TokenCoder.decode(token, config)
        user_repo = config.mappings[scope]
        user_repo.find_for_jwt_authentication(payload['sub'])
      end
    end
  end
end
