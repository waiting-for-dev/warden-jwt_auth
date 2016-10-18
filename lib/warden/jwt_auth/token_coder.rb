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
        blacklist = config.blacklist
        new.send(:decode, token, secret, blacklist)
      end

      private

      def encode(sub, expiration_time, secret)
        payload_to_encode = payload(sub, expiration_time)
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
