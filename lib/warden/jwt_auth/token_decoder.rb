# frozen_string_literal: true

module Warden
  module JWTAuth
    # Decodes a JWT into a hash payload into a JWT token
    class TokenDecoder
      include JWTAuth::Import['secret', 'algorithm']

      # Decodes the payload from a JWT as a hash
      #
      # @see JWT.decode for all the exceptions than can be raised when given
      # token is invalid
      #
      # @param token [String] a JWT
      # @return [Hash] payload decoded from the JWT
      def call(token)
        JWT.decode(token,
                   secret,
                   true,
                   algorithm: algorithm,
                   verify_jti: true)[0]
      end
    end
  end
end
