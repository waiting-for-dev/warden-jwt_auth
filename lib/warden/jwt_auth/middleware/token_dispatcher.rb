# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Dispatches a token (adds it to `Authorization` response header) if it
      # has been added to the request `env` by [Hooks]
      class TokenDispatcher < Middleware
        # Debugging key added to `env`
        ENV_KEY = 'warden-jwt_auth.token_dispatcher'

        attr_reader :app

        def initialize(app)
          @app = app
        end

        def call(env)
          env[ENV_KEY] = true
          status, headers, response = app.call(env)
          headers = headers_with_token(env, headers)
          [status, headers, response]
        end

        private

        def headers_with_token(env, headers)
          token = env[Hooks::PREPARED_TOKEN_ENV_KEY]
          token ? HeaderParser.to_headers(headers, token) : headers
        end
      end
    end
  end
end
