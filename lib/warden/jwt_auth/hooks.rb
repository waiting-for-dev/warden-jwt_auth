# frozen_string_literal: true

module Warden
  module JWTAuth
    # Warden hooks
    class Hooks
      attr_reader :config

      # `env` key where JWT is added
      PREPARED_TOKEN_ENV_KEY = 'warden-jwt_auth.token'

      # Adds a token for the signed in user to the request `env` if current path
      # matches with configuration. This will be picked up later on by a rack
      # middleware which will add it to the response headers.
      #
      # @see https://github.com/hassox/warden/wiki/Callbacks
      def self.after_set_user(user, auth, opts)
        new.send(:prepare_token, user, auth, opts)
      end

      def initialize
        @config = JWTAuth.config
      end

      private

      def prepare_token(user, auth, opts)
        env = auth.env
        scope = opts[:scope]
        return unless token_should_be_added?(scope, env)
        token = UserEncoder.new.call(user, scope)
        env[PREPARED_TOKEN_ENV_KEY] = token
      end

      def token_should_be_added?(scope, env)
        jwt_scope?(scope) && path_matches?(env)
      end

      def jwt_scope?(scope)
        jwt_scopes = config.mappings.keys
        jwt_scopes.include?(scope)
      end

      def path_matches?(env)
        dispatch_paths = config.dispatch_paths
        dispatch_paths && env['PATH_INFO'].match(dispatch_paths)
      end
    end
  end
end

Warden::Manager.after_set_user do |user, auth, opts|
  Warden::JWTAuth::Hooks.after_set_user(user, auth, opts)
end
