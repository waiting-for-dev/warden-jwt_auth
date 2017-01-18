# frozen_string_literal: true

require 'warden/jwt_auth/errors'

module Warden
  module JWTAuth
    # Layer above token decoding which directly decodes a user from a JWT
    class UserDecoder
      include JWTAuth::Import['revocation_strategies']

      attr_reader :helper

      def initialize(*args)
        super
        @helper = PayloadUserHelper
      end

      # Returns the user that is encoded in a JWT. The scope is used to choose
      # the user repository to which send `#find_for_jwt_authentication(sub)`
      # with decoded `sub` claim.
      #
      # @param token [String] a JWT
      # @param scope [Symbol] Warden scope
      # @return [Interfaces::User] an user, whatever it is
      # @raise [Errors::RevokedToken] when token has been revoked for the
      # encoded user
      # @raise [Errors::WrongScope] when encoded scope does not match with scope
      # argument
      def call(token, scope)
        payload = TokenDecoder.new.call(token)
        raise Errors::WrongScope unless helper.scope_matches?(payload, scope)
        user = helper.find_user(payload)
        raise Errors::RevokedToken if revoked?(payload, user, scope)
        user
      end

      private

      def revoked?(payload, user, scope)
        strategy = revocation_strategies[scope]
        strategy.jwt_revoked?(payload, user)
      end
    end
  end
end
