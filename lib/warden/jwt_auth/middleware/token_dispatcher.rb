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
          token = TokenCoder.encode(user.jwt_subject, config)
          HeaderParser.parse_to_headers(headers, token)
          call_revocation_hook(token)
        end

        def call_revocation_hook(token)
          revocation_strategy = config.revocation_strategy
          return unless revocation_strategy
          payload = JWT.decode(token, config.secret, true,
                               algorithm: TokenCoder::ALG,
                               verify_jti: true)[0]
          revocation_strategy.after_jwt_dispatch(payload)
        end
      end
    end
  end
end
