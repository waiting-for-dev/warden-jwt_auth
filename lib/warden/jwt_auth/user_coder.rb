# frozen_string_literal: true

require 'jwt'

module Warden
  module JWTAuth
    # Encode/decode a user
    class UserCoder
      def self.encode(user, scope, config = JWTAuth.config)
        new.send(:encode, user, scope, config)
      end

      def self.decode(user, scope, config = JWTAuth.config)
        new.send(:decode, user, scope, config)
      end

      private

      # :reek:UtilityFunction
      def encode(user, scope, config)
        sub = user.jwt_subject
        payload = merge_user_payload(user, sub: sub, scp: scope)
        TokenCoder.encode(payload, config)
      end

      # :reek:UtilityFunction
      # :reek:FeatureEnvy
      def decode(token, scope, config)
        payload = TokenCoder.decode(token, config)
        revocation_strategy = config.revocation_strategy
        check_if_revoked(payload, revocation_strategy) if revocation_strategy
        user_repo = config.mappings[scope]
        user_repo.find_for_jwt_authentication(payload['sub'])
      end

      # :reek:ManualDispatch
      # :reek:UtilityFunction
      def merge_user_payload(user, payload)
        return payload unless user.respond_to?(:jwt_payload)
        user.jwt_payload.merge(payload)
      end

      def check_if_revoked(payload, revocation_strategy)
        raise JWT::DecodeError if revocation_strategy.revoked?(payload)
      end
    end
  end
end
