# frozen_string_literal: true

require 'jwt'

module Warden
  module JWTAuth
    # Encode/decode a user
    class UserCoder
      attr_reader :config

      def self.encode(user, scope, config = JWTAuth.config)
        new(config).send(:encode, user, scope)
      end

      def self.decode(token, scope, config = JWTAuth.config)
        new(config).send(:decode, token, scope)
      end

      def initialize(config)
        @config = config
      end

      private

      def encode(user, scope)
        sub = user.jwt_subject
        payload = merge_user_payload(user, sub: sub, scp: scope)
        TokenCoder.encode(payload, config)
      end

      def decode(token, scope)
        payload = TokenCoder.decode(token, config)
        user_repo = config.mappings[scope]
        user = user_repo.find_for_jwt_authentication(payload['sub'])
        check_if_revoked(payload, user)
        user
      end

      # :reek:ManualDispatch
      # :reek:UtilityFunction
      def merge_user_payload(user, payload)
        return payload unless user.respond_to?(:jwt_payload)
        user.jwt_payload.merge(payload)
      end

      def check_if_revoked(payload, user)
        strategy = config.revocation_strategy
        raise JWT::DecodeError if strategy.revoked?(payload, user)
      end
    end
  end
end
