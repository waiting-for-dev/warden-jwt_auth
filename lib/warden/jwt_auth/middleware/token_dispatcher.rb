# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Adds JWT token to the response
      class TokenDispatcher < Middleware
        attr_reader :config

        def initialize(app, config)
          @app = app
          @config = config
        end

        def call(env)
          status, headers, response = @app.call(env)
          add_token_to_response(env, headers)
          [status, headers, response]
        end

        private

        def add_token_to_response(env, headers)
          user = env['warden'].user
          return unless user &&
                        env['PATH_INFO'].match(config.response_token_paths)
          token = Warden::JWTAuth::TokenCoder.encode({ sub: user.id }, config)
          headers['Authorization'] = "Bearer #{token}"
        end
      end
    end
  end
end
