# frozen_string_literal: true

require 'warden/jwt_auth/errors'

module Warden
  module Auth0
    # Layer above token decoding which directly decodes a user from a JWT
    class UserDecoder
      attr_reader :helper

      def initialize(**args)
        super
        @helper = PayloadUserHelper
      end

      # Returns the user that is encoded in a JWT.
      # @param token [String] a JWT
      # @param issuer [String] Expected issuer claim
      # @return [Interfaces::User] a user, whatever it is
      # @raise [Errors::NilUser] when decoded user is nil
      # @raise [Errors::WrongIssuer] when encoded issues does not match with issues argument
      def call(token, issuer)
        payload = TokenDecoder.new.call(token)
        check_valid_claims(payload, issuer)
        user = Warden::Auth0.config.user_resolver.call(payload)
        check_valid_user(user)
        user
      end

      private

      def check_valid_claims(payload, issuer)
        raise Warden::Auth0::Errors::WrongIssuer, 'wrong issuer' unless helper.issuer_matches?(payload, issuer)
      end

      def check_valid_user(user)
        raise Warden::Auth0::Errors::NilUser, 'nil user' unless user
      end
    end
  end
end
