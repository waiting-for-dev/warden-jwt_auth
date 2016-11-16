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
          manage_token_response(env, headers)
          [status, headers, response]
        end

        private

        def manage_token_response(env, headers)
          user = env['warden'].user
          return unless user &&
                        env['PATH_INFO'].match(config.response_token_paths)
          token = UserCoder.encode(user, config)
          HeaderParser.parse_to_headers(headers, token)
        end
      end
    end
  end
end
