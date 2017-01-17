# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Revokes a token if it request patch matches with configured
      class RevocationManager < Middleware
        # Debugging key added to `env`
        ENV_KEY = 'warden-jwt_auth.revocation_manager'

        attr_reader :app, :config

        def initialize(app)
          @app = app
          @config = JWTAuth.config
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
          return unless token && token_should_be_revoked?(env)
          TokenRevoker.new.call(token)
        end

        # :reek:FeatureEnvy
        def token_should_be_revoked?(env)
          revocation_requests = config.revocation_requests
          revocation_requests.each do |tuple|
            method, path = tuple
            return true if env['PATH_INFO'].match(path) &&
                           env['REQUEST_METHOD'] == method
          end
          false
        end
      end
    end
  end
end
