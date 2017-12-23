# frozen_string_literal: true

module Warden
  module JWTAuth
    # Helper functions to centralize working with rack env.
    #
    # It follows
    # [rack](http://www.rubydoc.info/github/rack/rack/file/SPEC#The_Environment)
    # and [PEP 333](https://www.python.org/dev/peps/pep-0333/#environ-variables)
    # conventions.
    module EnvHelper
      # Returns PATH_INFO environment variable
      #
      # @param env [Hash] Rack env
      # @return [String]
      def self.path_info(env)
        env['PATH_INFO'] || ''
      end

      # Returns REQUEST_METHOD environment variable
      #
      # @param env [Hash] Rack env
      # @return [String]
      def self.request_method(env)
        env['REQUEST_METHOD']
      end

      # Returns HTTP_AUTHORIZATION environment variable
      #
      # @param env [Hash] Rack env
      # @return [String]
      def self.authorization_header(env)
        env['HTTP_AUTHORIZATION']
      end

      # Returns a copy of `env` with value added to the `HTTP_AUTHORIZATION`
      # environment variable.
      #
      # Be aware than `env` is not modified in place and still an updated copy
      # is returned.
      #
      # @param env [Hash] Rack env
      # @param value [String]
      # @return [Hash] modified rack env
      def self.set_authorization_header(env, value)
        env = env.dup
        env['HTTP_AUTHORIZATION'] = value
        env
      end

      # Returns header configured through `aud_header` option
      #
      # @param env [Hash] Rack env
      # @return [String]
      def self.aud_header(env)
        env_name = ('HTTP_' + JWTAuth.config.aud_header.upcase).tr('-', '_')
        env[env_name]
      end
    end
  end
end
