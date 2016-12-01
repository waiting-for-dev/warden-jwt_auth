# frozen_string_literal: true

require 'warden/jwt_auth/errors'

module Warden
  module JWTAuth
    # Layer above token encryption which directly encodes/decodes a user to/from
    # a JWT
    class UserCoder
      attr_reader :config, :helper

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

      def initialize(config)
        @config = config
        @helper = PayloadUserHelper
      end

      private

      def encode(user, scope)
        payload = helper.payload_for_user(user, scope)
        TokenCoder.encode(payload, config)
      end

      def decode(token, scope)
        payload = TokenCoder.decode(token, config)
        raise Errors::WrongScope unless helper.scope_matches?(payload, scope)
        user = helper.find_user(payload, config)
        raise Errors::RevokedToken if revoked?(payload, user)
        user
      end

      def revoked?(payload, user)
        strategy = config.revocation_strategy
        strategy.revoked?(payload, user)
      end
    end
  end
end
