# frozen_string_literal: true

require 'devise/jwt/middleware/token_dispatcher'

module Devise
  module Jwt
    # Calls actual middlewares
    class Middleware
      attr_reader :config

      def initialize(app)
        @app = app
        @config = Devise::Jwt.config
      end

      def call(env)
        builder = Rack::Builder.new(@app)
        builder.use(TokenDispatcher, config)
        builder.run(@app)
        builder.call(env)
      end
    end
  end
end
