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

      # Encodes a user for given scope into a JWT. Payload generated includes a
      # `sub` claim which is build calling `jwt_subject` in `user`, and a custom
      # `scp` claim which value is `scope` as a string. The result of
      # calling `jwt_payload` in user is also merged into the payload.
      #
      # @param user [Interfaces::User] an user, whatever it is
      # @param scope [Symbol] Warden scope
      # @return [String] encoded JWT
      def call(user, scope)
        payload = helper.payload_for_user(user, scope)
        TokenEncoder.new.call(payload)
      end
    end
  end
end
