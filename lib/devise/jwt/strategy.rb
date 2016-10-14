# frozen_string_literal: true

require 'warden'

module Devise
  module Jwt
    # JWT strategy
    # :reek:PrimmaDonnaMethod
    class Strategy < Warden::Strategies::Base
      def valid?
        env['HTTP_AUTHORIZATION']
      end

      def authenticate!
        token = env['HTTP_AUTHORIZATION'].split.last
        config = Devise::Jwt.config
        payload = Devise::Jwt::TokenCoder.decode(token, config)
        mapping = config.mappings[scope]
        user = mapping.find_for_jwt_authentication(payload['sub'])
        success!(user)
      rescue ::JWT::DecodeError
        fail!
      end
    end
  end
end
