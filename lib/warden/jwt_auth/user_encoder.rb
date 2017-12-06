# frozen_string_literal: true

require 'warden/jwt_auth/errors'

module Warden
  module JWTAuth
    # Layer above token encoding which directly encodes a user to a JWT
    class UserEncoder
      attr_reader :helper

      def initialize
        @helper = PayloadUserHelper
      end

      # Encodes a user for given scope into a JWT.
      #
      # Payload generated includes:
      #
      # - a `sub` claim which is build calling `jwt_subject` in `user`
      # - an `aud` claim taken as it is in the `aud` parameter
      # - a custom `scp` claim taken as the value of the `scope` parameter
      # as a string.
      #
      # The result of calling `jwt_payload` in user is also merged
      # into the payload.
      #
      # @param user [Interfaces::User] an user, whatever it is
      # @param scope [Symbol] Warden scope
      # @param aud [String] JWT aud claim
      # @return [String, String] encoded JWT and decoded payload
      def call(user, scope, aud)
        payload = helper.payload_for_user(user, scope).merge('aud' => aud)
        token = TokenEncoder.new.call(payload)
        [token, payload]
      end
    end
  end
end
