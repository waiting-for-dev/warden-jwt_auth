# frozen_string_literal: true

module Warden
  module JWTAuth
    # Revokes a JWT using configured revocation strategy
    class TokenRevoker
      include JWTAuth::Import['revocation_strategies']

      # Revokes the JWT token
      #
      # @param token [String] a JWT
      def call(token)
        payload = TokenDecoder.new.call(token)
        scope = payload['scp'].to_sym
        user = PayloadUserHelper.find_user(payload)
        revocation_strategies[scope].revoke_jwt(payload, user)
      # rubocop:disable Lint/SuppressedException
      rescue JWT::ExpiredSignature
      end
      # rubocop:enable Lint/SuppressedException
    end
  end
end
