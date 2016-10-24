# frozen_string_literal: true

require 'warden/jwt_auth/middleware/token_dispatcher'
require 'warden/jwt_auth/middleware/blacklist_manager'

module Warden
  module JWTAuth
    # Calls two actual middlewares
    class Middleware
      attr_reader :app, :config

      def initialize(app)
        @app = app
        @config = JWTAuth.config
      end

      def call(env)
        warden_proxy = env['warden']
        unless warden_proxy
          raise "#{self.class.name} must be called after Warden"
        end
        warden_proxy.user ? call_with_middlewares(app, env) : app.call(env)
      end

      private

      # :reek:FeatureEnvy
      def call_with_middlewares(app, env)
        builder = Rack::Builder.new(app)
        builder.use(BlacklistManager, config)
        builder.use(TokenDispatcher, config)
        builder.run(app)
        builder.call(env)
      end

      def warden_proxy
        env['warden']
      end
    end
  end
end
