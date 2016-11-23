# frozen_string_literal: true

module Warden
  module JWTAuth
    # Encodes/decodes a payload into a JWT token, adding some configurable
    # claims
    class TokenCoder
      # Algorithm used to encode
      ALG = 'HS256'

      attr_reader :config

      # Encodes a payload into a JWT
      #
      # @param payload [Hash] what has to be encoded
      # @return [String] JWT
      def self.encode(payload, config = JWTAuth)
        new(config).send(:encode, payload)
      end

      # Decodes the payload from a JWT as a hash
      #
      # @param token [String] a JWT
      # @return [Hash] payload decoded from the JWT
      def self.decode(token, config = JWTAuth)
        new(config).send(:decode, token)
      end

      def initialize(config)
        @config = config
      end

      private

      def encode(payload)
        expiration_time = config.expiration_time
        secret = config.secret
        payload_to_encode = build_payload(payload, expiration_time)
        JWT.encode(payload_to_encode, secret, ALG)
      end

      def decode(token)
        secret = config.secret
        JWT.decode(token,
                   secret,
                   true,
                   algorithm: ALG,
                   verify_jti: true)[0]
      end

      # :reek:UtilityFunction
      def build_payload(payload, expiration_time)
        now = Time.now.to_i
        {
          iat: now,
          exp: now + expiration_time,
          jti: SecureRandom.uuid
        }.merge(payload)
      end
    end
  end
end
