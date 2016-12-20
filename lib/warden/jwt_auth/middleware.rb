# frozen_string_literal: true

require 'warden/jwt_auth/middleware/token_dispatcher'
require 'warden/jwt_auth/middleware/revocation_manager'

module Warden
  module JWTAuth
    # Simple rack middleware which is just a wrapper for other middlewares which
    # actually perform some work.
    class Middleware
      attr_reader :app

      def initialize(app)
        @app = app
      end

      # :reek:FeatureEnvy
      def call(env)
        builder = Rack::Builder.new
        builder.use(RevocationManager)
        builder.use(TokenDispatcher)
        builder.run(app)
        builder.call(env)
      end
    end
  end
end
