# frozen_string_literal: true

require 'warden'

module Warden
  module Auth0
    # Warden strategy to authenticate a user through a JWT token in the
    # `Authorization` request header
    class Strategy < Warden::Strategies::Base
      def valid?
        token_exists? && issuer_claim_valid?
      end

      def store?
        false
      end

      def authenticate!
        configured_issuer = Warden::Auth0.config.issuer
        user = UserDecoder.new.call(token, configured_issuer)
        success!(user)
      rescue JWT::DecodeError => e
        fail!(e.message)
      end

      private

      def issuer_claim_valid?
        configured_issuer = Warden::Auth0.config.issuer
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

Warden::Strategies.add(:auth0, Warden::Auth0::Strategy)
