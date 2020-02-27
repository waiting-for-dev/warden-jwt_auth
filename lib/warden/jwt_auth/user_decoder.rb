# frozen_string_literal: true

require 'warden/jwt_auth/errors'

module Warden
  module JWTAuth
    # Layer above token decoding which directly decodes a user from a JWT
    class UserDecoder
      include JWTAuth::Import['revocation_strategies']

      attr_reader :helper

      def initialize(**args)
        super
        @helper = PayloadUserHelper
      end

      # Returns the user that is encoded in a JWT. The scope is used to choose
      # the user repository to which send `#find_for_jwt_authentication(sub)`
      # with decoded `sub` claim.
      #
      # @param token [String] a JWT
      # @param scope [Symbol] Warden scope
      # @param aud [String] Expected aud claim
      # @return [Interfaces::User] an user, whatever it is
      # @raise [Errors::RevokedToken] when token has been revoked for the
      # encoded user
      # @raise [Errors::NilUser] when decoded user is nil
      # @raise [Errors::WrongScope] when encoded scope does not match with scope
      # @raise [Errors::WrongAud] when encoded aud does not match with aud
      # argument
      def call(token, scope, aud)
        payload = TokenDecoder.new.call(token)
        check_valid_claims(payload, scope, aud)
        user = helper.find_user(payload)
        check_valid_user(payload, user, scope)
        user
      end

      private

      def check_valid_claims(payload, scope, aud)
        raise Errors::WrongScope, 'wrong scope' unless helper.scope_matches?(payload, scope)
        raise Errors::WrongAud, 'wrong aud' unless helper.aud_matches?(payload, aud)
      end

      def check_valid_user(payload, user, scope)
        raise Errors::NilUser, 'nil user' unless user

        strategy = revocation_strategies[scope]
        raise Errors::RevokedToken, 'revoked token' if strategy.jwt_revoked?(payload, user)
      end
    end
  end
end
