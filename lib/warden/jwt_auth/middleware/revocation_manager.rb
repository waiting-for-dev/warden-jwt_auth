# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Revokes a token if it request patch matches with configured
      class RevocationManager < Middleware
        # Debugging key added to `env`
        ENV_KEY = 'warden-jwt_auth.revocation_manager'

        attr_reader :app, :config

        def initialize(app, config = JWTAuth.config)
          @app = app
          @config = config
        end

        def call(env)
          env[ENV_KEY] = true
          response = app.call(env)
          revoke_token(env)
          response
        end

        private

        def revoke_token(env)
          token = HeaderParser.from_env(env)
          return unless token && token_should_be_added?(env)
          payload = TokenDecoder.new(config).call(token)
          user = PayloadUserHelper.find_user(payload, config)
          config.revocation_strategy.revoke(payload, user)
        end

        def token_should_be_added?(env)
          revocation_paths = config.revocation_paths
          revocation_paths && env['PATH_INFO'].match(revocation_paths)
        end
      end
    end
  end
end
