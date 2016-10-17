# frozen_string_literal: true

module Warden
  module JWTAuth
    # Helpers to take/put token from/to headers
    module HeaderParser
      METHOD = 'Bearer'

      def self.parse_from_env(env)
        auth = env['HTTP_AUTHORIZATION']
        return nil unless auth
        method, token = auth.split
        method == METHOD ? token : nil
      end

      def self.parse_to_headers(headers, token)
        headers['Authorization'] = "#{METHOD} #{token}"
      end
    end
  end
end
