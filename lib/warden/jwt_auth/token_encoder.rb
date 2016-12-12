# frozen_string_literal: true

module Warden
  module JWTAuth
    # Encodes a payload into a JWT token, adding some configurable
    # claims
    class TokenEncoder
      # Algorithm used to encode
      ALG = 'HS256'

      attr_reader :config

      def initialize(config = JWTAuth.config)
        @config = config
      end

      # Encodes a payload into a JWT
      #
      # @param payload [Hash] what has to be encoded
      # @return [String] JWT
      def call(payload)
        secret = config.secret
        payload_to_encode = merge_with_default_claims(payload)
        JWT.encode(payload_to_encode, secret, ALG)
      end

      private

      def merge_with_default_claims(payload)
        now = Time.now.to_i
        {
          iat: now,
          exp: now + config.expiration_time,
          jti: SecureRandom.uuid
        }.merge(payload)
      end
    end
  end
end
