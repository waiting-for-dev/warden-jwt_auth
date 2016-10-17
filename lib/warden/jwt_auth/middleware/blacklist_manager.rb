# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Adds JWT to the blacklist
      class BlacklistManager < Middleware
        attr_reader :config

        def initialize(app, config)
          @app = app
          @config = config
        end

        def call(env)
          add_token_to_blacklist(env)
          @app.call(env)
        end

        private

        def add_token_to_blacklist(env)
          return unless env['PATH_INFO'].match(config.blacklist_token_paths)
          token = env['HTTP_AUTHORIZATION'].split.last
          jti = Warden::JWTAuth::TokenCoder.decode(token, config)['jti']
          config.blacklist.push(jti)
        end
      end
    end
  end
end
