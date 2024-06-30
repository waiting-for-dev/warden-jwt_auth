# frozen_string_literal: true

require 'warden'

module Warden
  module JWTAuth
    # Warden strategy to authenticate an user through a JWT token in the
    # `Authorization` request header
    class Strategy < Warden::Strategies::Base
      def valid?
        token_exists? && issuer_claim_valid?
      end

      def store?
        false
      end

      def authenticate!
        aud = EnvHelper.aud_header(env)
        user = UserDecoder.new.call(token, scope, aud)
        success!(user)
      rescue JWT::DecodeError => e
        fail!(e.message)
      end

      private

      def issuer_claim_valid?
        configured_issuer = Warden::JWTAuth.config.issuer
        return true if configured_issuer.nil?

        payload = TokenDecoder.new.call(token)
        PayloadUserHelper.issuer_matches?(payload, configured_issuer)
      rescue JWT::DecodeError
        true
      end

      def token_exists?
        !token.nil?
      end

      def token
        @token ||= HeaderParser.from_env(env)
      end
    end
  end
end

Warden::Strategies.add(:jwt, Warden::JWTAuth::Strategy)
