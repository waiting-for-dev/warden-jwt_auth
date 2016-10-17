# frozen_string_literal: true

require 'warden'

module Warden
  module JWTAuth
    # JWT strategy
    # :reek:PrimmaDonnaMethod
    class Strategy < Warden::Strategies::Base
      def valid?
        env['HTTP_AUTHORIZATION']
      end

      def authenticate!
        token = env['HTTP_AUTHORIZATION'].split.last
        config = Warden::JWTAuth.config
        payload = Warden::JWTAuth::TokenCoder.decode(token, config)
        mapping = config.mappings[scope]
        user = mapping.find_for_jwt_authentication(payload['sub'])
        success!(user)
      rescue ::JWT::DecodeError
        fail!
      end
    end
  end
end

Warden::Strategies.add(:jwt, Warden::JWTAuth::Strategy)
