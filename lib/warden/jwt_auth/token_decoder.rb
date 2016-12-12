# frozen_string_literal: true

module Warden
  module JWTAuth
    # Decodes a JWT into a hash payload into a JWT token
    class TokenDecoder
      attr_reader :config

      def initialize(config = JWTAuth.config)
        @config = config
      end

      # Decodes the payload from a JWT as a hash
      #
      # @param token [String] a JWT
      # @return [Hash] payload decoded from the JWT
      def call(token)
        secret = config.secret
        JWT.decode(token,
                   secret,
                   true,
                   algorithm: TokenEncoder::ALG,
                   verify_jti: true)[0]
      end
    end
  end
end
