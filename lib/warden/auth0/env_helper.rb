# frozen_string_literal: true

module Warden
  module Auth0
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

      # Returns header configured through `token_header` option
      #
      # @param env [Hash] Rack env
      # @return [String]
      def self.authorization_header(env)
        header_env_name = env_name(Auth0.config.token_header)
        env[header_env_name]
      end

      # Returns a copy of `env` with value added to the environment variable
      # configured through `token_header` option
      #
      # Be aware than `env` is not modified in place and still an updated copy
      # is returned.
      #
      # @param env [Hash] Rack env
      # @param value [String]
      # @return [Hash] modified rack env
      def self.set_authorization_header(env, value)
        env = env.dup
        header_env_name = env_name(Auth0.config.token_header)
        env[header_env_name] = value
        env
      end

      # Returns the ENV name for a given header
      #
      # @param header [String] Header name
      # @return [String]
      def self.env_name(header)
        ('HTTP_' + header.upcase).tr('-', '_')
      end
    end
  end
end
