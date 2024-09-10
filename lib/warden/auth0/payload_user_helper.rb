# frozen_string_literal: true

module Warden
  module Auth0
    # Helper functions to deal with user info present in a decode payload
    module PayloadUserHelper
      # Returns whether given scope matches with the one encoded in the payload
      # @param payload [Hash] JWT payload
      # @return [Boolean]
      def self.scope_matches?(payload, scope)
        payload['scp'] == scope.to_s
      end

      # Returns whether given aud matches with the one encoded in the payload
      # @param payload [Hash] JWT payload
      # @return [Boolean]
      def self.aud_matches?(payload, aud)
        payload['aud'] == aud
      end

      # Returns whether given issuer matches with the one encoded in the payload
      # @param payload [Hash] JWT payload
      # @param issuer [String] The issuer to match
      # @return [Boolean]
      def self.issuer_matches?(payload, issuer)
        payload['iss'] == issuer.to_s
      end
    end
  end
end
