# frozen_string_literal: true

module Warden
  module JWTAuth
    # Revokes a JWT using configured revocation strategy
    class TokenRevoker
      include JWTAuth::Import['revocation_strategy']

      # Revokes the JWT token
      #
      # @param token [String] a JWT
      def call(token)
        payload = TokenDecoder.new.call(token)
        user = PayloadUserHelper.find_user(payload)
        revocation_strategy.revoke(payload, user)
      end
    end
  end
end
