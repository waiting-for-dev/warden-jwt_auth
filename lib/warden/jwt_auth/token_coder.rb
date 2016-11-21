# frozen_string_literal: true

require 'jwt'

module Warden
  module JWTAuth
    # Encode/decode a token, adding some configurable claims to the payload
    class TokenCoder
      ALG = 'HS256'

      def self.encode(payload, config)
        secret = config.secret
        expiration_time = config.expiration_time
        new.send(:encode, payload, expiration_time, secret)
      end

      def self.decode(token, config)
        secret = config.secret
        new.send(:decode, token, secret)
      end

      private

      def encode(payload, expiration_time, secret)
        payload_to_encode = default_payload(expiration_time).merge(payload)
        JWT.encode(payload_to_encode, secret, ALG)
      end

      # :reek:UtilityFunction
      def decode(token, secret)
        JWT.decode(token, secret, true,
                   algorithm: ALG,
                   verify_jti: true)[0]
      end

      # :reek:UtilityFunction
      def default_payload(expiration_time)
        now = Time.now.to_i
        {
          iat: now,
          exp: now + expiration_time,
          jti: SecureRandom.uuid
        }
      end
    end
  end
end
