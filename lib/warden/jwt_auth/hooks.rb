# frozen_string_literal: true

module Warden
  module JWTAuth
    # Warden hooks
    class Hooks
      attr_reader :config

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
        token = UserCoder.encode(user, scope)
        env['warden-jwt_auth.token'] = token
      end

      def token_should_be_added?(scope, env)
        jwt_scopes = config.mappings.keys
        return false unless jwt_scopes.include?(scope)
        return false unless env['PATH_INFO'].match(config.response_token_paths)
        true
      end
    end
  end
end

Warden::Manager.after_set_user do |user, auth, opts|
  Warden::JWTAuth::Hooks.after_set_user(user, auth, opts)
end
