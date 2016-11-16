# frozen_string_literal: true

require 'warden'

module Warden
  module JWTAuth
    # JWT strategy
    # :reek:PrimmaDonnaMethod
    class Strategy < Warden::Strategies::Base
      attr_reader :token

      def valid?
        !token.nil?
      end

      def store?
        false
      end

      def authenticate!
        user = UserCoder.decode(token, scope)
        success!(user)
      rescue JWT::DecodeError
        fail!
      end

      private

      def token
        @token ||= HeaderParser.parse_from_env(env)
      end
    end
  end
end

Warden::Strategies.add(:jwt, Warden::JWTAuth::Strategy)
