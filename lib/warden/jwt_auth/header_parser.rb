# frozen_string_literal: true

module Warden
  module JWTAuth
    # Helpers to parse token from a request and to a response
    module HeaderParser
      # Method for `Authorization` header. Token is present in request/response
      # headers as `Bearer #{token}`
      METHOD = 'Bearer'

      # Parses the token from a rack request
      #
      # @param env [Hash] rack env hash
      # @return [String] JWT token
      # @return [nil] if token is not present
      def self.from_env(env)
        auth = env['HTTP_AUTHORIZATION']
        return nil unless auth
        method, token = auth.split
        method == METHOD ? token : nil
      end

      # Parses the token to rack `env`
      #
      # @param env [Hash] rack env hash
      # @param token [String] JWT token
      # @return [Hash] modified rack env
      def self.to_env(env, token)
        env['HTTP_AUTHORIZATION'] = "#{METHOD} #{token}"
      end

      # Adds a token to response headers
      #
      # @param headers [Hash] rack hash response headers
      # @param token [String] JWT token
      # @return [Hash] response headers with the token added
      def self.to_headers(headers, token)
        headers['Authorization'] = "#{METHOD} #{token}"
      end
    end
  end
end
