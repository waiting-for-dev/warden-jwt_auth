# frozen_string_literal: true

module Warden
  module JWTAuth
    # Warden hooks
    class Hooks
      include JWTAuth::Import['mappings', 'dispatch_requests', 'aud_header']

      # `env` key where JWT is added
      PREPARED_TOKEN_ENV_KEY = 'warden-jwt_auth.token'

      # Adds a token for the signed in user to the request `env` if current path
      # and verb match with configuration. This will be picked up later on by a
      # rack middleware which will add it to the response headers.
      #
      # @see https://github.com/hassox/warden/wiki/Callbacks
      def self.after_set_user(user, auth, opts)
        new.send(:prepare_token, user, auth, opts)
      end

      private

      def prepare_token(user, auth, opts)
        env = auth.env
        scope = opts[:scope]
        return unless token_should_be_added?(scope, env)
        token = UserEncoder.new.call(user, scope, env[aud_header])
        env[PREPARED_TOKEN_ENV_KEY] = token
      end

      def token_should_be_added?(scope, env)
        path_info = EnvHelper.path_info(env)
        method = EnvHelper.request_method(env)
        jwt_scope?(scope) && request_matches?(path_info, method)
      end

      def jwt_scope?(scope)
        jwt_scopes = mappings.keys
        jwt_scopes.include?(scope)
      end

      # :reek:ControlParameter
      def request_matches?(path_info, method)
        dispatch_requests.each do |tuple|
          dispatch_method, dispatch_path = tuple
          return true if path_info.match(dispatch_path) &&
                         method == dispatch_method
        end
        false
      end
    end
  end
end

Warden::Manager.after_set_user do |user, auth, opts|
  Warden::JWTAuth::Hooks.after_set_user(user, auth, opts)
end
