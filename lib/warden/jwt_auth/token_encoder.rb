# frozen_string_literal: true

require 'securerandom'

module Warden
  module JWTAuth
    # Encodes a payload into a JWT token, adding some configurable
    # claims
    class TokenEncoder
      include JWTAuth::Import['secret', 'algorithm', 'expiration_time']

      # Encodes a payload into a JWT
      #
      # @param payload [Hash] what has to be encoded
      # @return [String] JWT
      def call(payload)
        payload_to_encode = merge_with_default_claims(payload)
        JWT.encode(payload_to_encode, secret, algorithm)
      end

      private

      def merge_with_default_claims(payload)
        now = Time.now.to_i
        payload['iat'] ||= now
        payload['exp'] ||= now + expiration_time
        payload['jti'] ||= SecureRandom.uuid
        payload
      end
    end
  end
end
