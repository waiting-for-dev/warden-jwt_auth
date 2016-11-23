# frozen_string_literal: true

require 'warden/jwt_auth/middleware/token_dispatcher'
require 'warden/jwt_auth/middleware/revocation_manager'

module Warden
  module JWTAuth
    # Simple rack middleware which is just a wrapper for other middlewares which
    # actually perform some work.
    class Middleware
      attr_reader :app, :config

      def initialize(app, config = JWTAuth.config)
        @app = app
        @config = config
      end

      def call(env)
        builder = Rack::Builder.new
        add_middlewares(builder)
        builder.run(app)
        builder.call(env)
      end

      private

      def add_middlewares(builder)
        builder.use(RevocationManager, config)
        builder.use(TokenDispatcher, config)
      end
    end
  end
end
