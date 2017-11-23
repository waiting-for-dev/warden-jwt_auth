# frozen_string_literal: true

require 'warden'

module Warden
  module JWTAuth
    # Warden strategy to authenticate an user through a JWT token in the
    # `Authorization` request header
    # :reek:PrimaDonnaMethod
    class Strategy < Warden::Strategies::Base
      # :reek:NeelCheck
      def valid?
        !token.nil?
      end

      def store?
        false
      end

      def authenticate!
        user = UserDecoder.new.call(token, scope)
        success!(user)
      rescue JWT::DecodeError => e
        fail!(e.message)
      end

      private

      def token
        @token ||= HeaderParser.from_env(env)
      end
    end
  end
end

Warden::Strategies.add(:jwt, Warden::JWTAuth::Strategy)
