# frozen_string_literal: true

require 'warden'

module Warden
  module JWTAuth
    # Warden strategy to authenticate an user through a JWT token in the
    # `Authorization` request header
    # :reek:PrimaDonnaMethod
    class Strategy < Warden::Strategies::Base
      # :reek:NilCheck
      def valid?
        !token.nil?
      end

      def store?
        false
      end

      def authenticate!
        aud = EnvHelper.aud_header(env)
        user = UserDecoder.new.call(token, scope, aud)
        success!(user)
      rescue JWT::DecodeError => exception
        fail!(exception.message)
      end

      private

      def token
        @token ||= HeaderParser.from_env(env)
      end
    end
  end
end

Warden::Strategies.add(:jwt, Warden::JWTAuth::Strategy)
