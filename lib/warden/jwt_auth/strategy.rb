# frozen_string_literal: true

require 'warden'

module Warden
  module JWTAuth
    # Warden strategy to authenticate an user through a JWT token in the
    # `Authorization` request header
    class Strategy < Warden::Strategies::Base
      def valid?
        issuer_claim_configured? ? issuer_claim_matches? : token_exists?
      rescue JWT::DecodeError
        true
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

      def token_exists?
        !token.nil?
      end

      def token
        @token ||= HeaderParser.from_env(env)
      end

      def issuer_claim_configured?
        !Warden::JWTAuth.config.issuer.nil?
      end

      def issuer_claim_matches?
        PayloadUserHelper.issuer_matches?(TokenDecoder.new.call(token), Warden::JWTAuth.config.issuer)
      end
    end
  end
end

Warden::Strategies.add(:jwt, Warden::JWTAuth::Strategy)
