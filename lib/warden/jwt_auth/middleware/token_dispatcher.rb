# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Adds JWT token to the response
      class TokenDispatcher < Middleware
        ENV_KEY = 'warden-jwt_auth.token_dispatcher'

        attr_reader :config

        def initialize(app, config)
          @app = app
          @config = config
        end

        def call(env)
          env[ENV_KEY] = true
          status, headers, response = @app.call(env)
          add_token_to_response(env, headers)
          [status, headers, response]
        end

        private

        # :reek:UtilityFunction
        def add_token_to_response(env, headers)
          token = env['warden-jwt_auth.token']
          HeaderParser.parse_to_headers(headers, token) if token
        end
      end
    end
  end
end
