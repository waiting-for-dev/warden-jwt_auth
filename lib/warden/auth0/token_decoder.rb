# frozen_string_literal: true

require 'jwt/error'

module Warden
  module Auth0
    # Decodes a JWT into a hash payload into a JWT token
    class TokenDecoder
      include Auth0::Import['algorithm', 'jwks']

      # Decodes the payload from a JWT as a hash
      #
      # @see JWT.decode for all the exceptions than can be raised when given
      # token is invalid
      #
      # @param token [String] a JWT
      # @return [Hash] payload decoded from the JWT
      def call(token)
        decode(token)
      end

      private

      def decode(token)
        JWT.decode(token, nil, true, algorithms: algorithm, jwks: jwks)[0]
      end
    end
  end
end
