# frozen_string_literal: true

require 'warden/jwt_auth/errors'

module Warden
  module JWTAuth
    # Layer above token encryption which directly encodes/decodes a user to/from
    # a JWT
    class UserCoder
      attr_reader :config

      # Encodes a user for given scope into a JWT. Payload generated includes a
      # `sub` claim which is build calling `jwt_subject` in `user`, and a custom
      # `scp` claim which value is `scope` as a string. The result of
      # calling `jwt_payload` in user is also merged into the payload.
      #
      # @param user [#jwt_subject#jwt_payload] an user, whatever it is
      # @param scope [Symbol] Warden scope
      # @return [String] encoded JWT
      def self.encode(user, scope, config = JWTAuth.config)
        new(config).send(:encode, user, scope)
      end

      # Returns the user that is encoded in a JWT. The scope is used to choose
      # the user repository to which send `#find_for_jwt_authentication(sub)`
      # with decoded `sub` claim.
      #
      # @param token [String] a JWT
      # @param scope [Symbol] Warden scope
      # @return [#jwt_subject#jwt_payload] an user, whatever it is
      # @raise [Errors::RevokedToken] when token has been revoked for the
      # encoded user
      # @raise [Errors::WrongScope] when encoded scope does not match with scope
      # argument
      def self.decode(token, scope, config = JWTAuth.config)
        new(config).send(:decode, token, scope)
      end

      def self.decode_from_payload(payload, config = JWTAuth.config)
        new(config).send(:decode_from_payload, payload)
      end

      def initialize(config)
        @config = config
      end

      private

      def encode(user, scope)
        payload = payload_to_ecode(user, scope)
        TokenCoder.encode(payload, config)
      end

      def decode(token, scope)
        payload = TokenCoder.decode(token, config)
        raise Errors::WrongScope if wrong_scope?(payload, scope)
        user = decode_from_payload(payload)
        raise Errors::RevokedToken if revoked?(payload, user)
        user
      end

      # :reek:FeatureEnvy
      def decode_from_payload(payload)
        scope = payload['scp'].to_sym
        user_repo = config.mappings[scope]
        user_repo.find_for_jwt_authentication(payload['sub'])
      end

      # :reek:ManualDispatch
      # :reek:UtilityFunction
      def payload_to_ecode(user, scope)
        sub = user.jwt_subject
        payload = { sub: sub, scp: scope }
        return payload unless user.respond_to?(:jwt_payload)
        user.jwt_payload.merge(payload)
      end

      def revoked?(payload, user)
        strategy = config.revocation_strategy
        strategy.revoked?(payload, user)
      end

      # :reek:UtilityFunction
      def wrong_scope?(payload, scope)
        payload['scp'] != scope.to_s
      end
    end
  end
end
