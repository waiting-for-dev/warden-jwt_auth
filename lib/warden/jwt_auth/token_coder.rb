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
        new.send(:encode, payload, secret, expiration_time)
      end

      def self.decode(token, config)
        secret = config.secret
        blacklist = config.blacklist
        new.send(:decode, token, secret, blacklist)
      end

      private

      def encode(payload, secret, expiration_time)
        payload_to_encode = base_payload(expiration_time).merge(payload)
        JWT.encode(payload_to_encode, secret, ALG)
      end

      def decode(token, secret, blacklist)
        payload = JWT.decode(token, secret, true,
                             algorithm: ALG,
                             verify_jti: true)[0]
        check_in_blacklist(payload, blacklist) if blacklist
        payload
      end

      def check_in_blacklist(payload, blacklist)
        raise JWT::DecodeError if blacklist.member?(payload['jti'])
      end

      # :reek:UtilityFunction
      def base_payload(expiration_time)
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
