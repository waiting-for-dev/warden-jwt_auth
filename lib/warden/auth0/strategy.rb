# frozen_string_literal: true

require 'warden'

module Warden
  module Auth0
    # Warden strategy to authenticate a user through a JWT token in the
    # `Authorization` request header
    class Strategy < Warden::Strategies::Base
      def valid?
        token_exists? && issuer_claim_valid? && aud_claim_valid?
      end

      def store?
        false
      end

      def authenticate!
        raise Errors::WrongIssuer, 'wrong issuer' unless issuer_claim_valid?

        raise Errors::WrongAud, 'wrong audience' unless aud_claim_valid?

        method = "#{scope}_resolver"
        raise "unimplemented resolver #{method}" unless respond_to?(method)

        user = send(method, decoded_token)

        raise Warden::Auth0::Errors::NilUser, 'nil user' unless user

        success!(user)
      rescue JWT::DecodeError => e
        puts "Failing to authenticate with #{e.message}"
        fail!(e.message)
      end

      private

      def issuer_claim_valid?
        issuer = configured_issuer
        issuer_matches?(decoded_token, issuer)
      rescue JWT::DecodeError
        false
      end

      def aud_claim_valid?
        aud = configured_aud
        aud_matches?(decoded_token, aud)
      rescue JWT::DecodeError
        false
      end

      def decoded_token
        TokenDecoder.new.call(token)
      end

      def configured_aud
        configured_aud = Warden::Auth0.config.aud
        raise Errors::NoConfiguredAud if configured_aud.nil?

        configured_aud
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
        if issuer.is_a?(String)
          payload['iss'] == issuer.to_s
        elsif issuer.is_a?(Array)
          issuer.map(&:to_s).include(payload['iss'])
        end

        false
      end

      def aud_matches?(payload, aud)
        if aud.is_a?(String)
          return true if payload['aud'] == aud.to_s

          payload['aud'].is_a?(Array) && payload['aud'].include?(aud)
        elsif aud.is_a?(Array)
          return true if aud.include?(payload['aud'])

          payload['aud'].is_a?(Array) && (payload['aud'] & aud).any?
        end
        
        false
      end

      def token
        @token ||= HeaderParser.from_env(env)
      end
    end
  end
end
