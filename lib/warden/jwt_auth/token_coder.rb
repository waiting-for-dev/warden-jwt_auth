# frozen_string_literal: true

require 'jwt'

module Warden
  module JWTAuth
    # Encode/decode a token, adding some configurable claims to the payload
    class TokenCoder
      ALG = 'HS256'

      def self.encode(sub, config)
        secret = config.secret
        expiration_time = config.expiration_time
        new.send(:encode, sub, expiration_time, secret)
      end

      def self.decode(token, config)
        secret = config.secret
        revocation_strategy = config.revocation_strategy
        new.send(:decode, token, secret, revocation_strategy)
      end

      private

      def encode(sub, expiration_time, secret)
        payload_to_encode = payload(sub, expiration_time)
        JWT.encode(payload_to_encode, secret, ALG)
      end

      def decode(token, secret, revocation_strategy)
        payload = JWT.decode(token, secret, true,
                             algorithm: ALG,
                             verify_jti: true)[0]
        check_if_revoked(payload, revocation_strategy) if revocation_strategy
        payload
      end

      def check_if_revoked(payload, revocation_strategy)
        raise JWT::DecodeError if revocation_strategy.revoked?(payload)
      end

      # :reek:UtilityFunction
      def payload(sub, expiration_time)
        now = Time.now.to_i
        {
          sub: sub,
          iat: now,
          exp: now + expiration_time,
          jti: SecureRandom.uuid
        }
      end
    end
  end
end
