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
        raise Errors::WrongIssuer, 'wrong issuer' unless issuer_claim_valid?

        user = Warden::Auth0.config.user_resolver.call(decoded_token)

        raise Warden::Auth0::Errors::NilUser, 'nil user' unless user

        success!(user)
      rescue JWT::DecodeError => e
        fail!(e.message)
      end

      private

      def issuer_claim_valid?
        issuer = configured_issuer
        issuer_matches?(decoded_token, issuer)
      rescue JWT::DecodeError
        false
      end

      def decoded_token
        TokenDecoder.new.call(token)
      end

      def configured_issuer
        configured_issuer = Warden::Auth0.config.issuer
        raise Errors::NoConfiguredIssuer if configured_issuer.nil?

        configured_issuer
      end

      def token_exists?
        !token.nil?
      end

      def issuer_matches?(payload, issuer)
        payload['iss'] == issuer.to_s
      end

      def token
        @token ||= HeaderParser.from_env(env)
      end
    end
  end
end

Warden::Strategies.add(:auth0, Warden::Auth0::Strategy)
