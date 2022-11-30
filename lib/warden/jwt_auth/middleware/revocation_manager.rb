# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Revokes a token if it path and method match with configured
      class RevocationManager < Middleware
        # Debugging key added to `env`
        ENV_KEY = 'warden-jwt_auth.revocation_manager'

        attr_reader :app, :config, :helper

        def initialize(app)
          @app = app
          @config = JWTAuth.config
          @helper = EnvHelper
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
          path_info = EnvHelper.path_info(env)
          method = EnvHelper.request_method(env)
          body_string_io = Rack::Request.new(env).body
          return unless token && token_should_be_revoked?(path_info, method, body_string_io)
          TokenRevoker.new.call(token)
        end

        def token_should_be_revoked?(path_info, method, body_string_io)
          revocation_requests = config.revocation_requests
          revocation_requests.each do |tuple|
            revocation_method, revocation_path, revocation_body = tuple
            return true if path_info.match(revocation_path) &&
                           method == revocation_method &&
                           (revocation_body ? body_string_io.string.match(revocation_body) : true)
          end
          false
        end
      end
    end
  end
end
