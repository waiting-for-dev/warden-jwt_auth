# frozen_string_literal: true

module Warden
  module JWTAuth
    # Helper functions to deal with user info present in a decode payload
    module PayloadUserHelper
      # Returns user encoded in given payload
      #
      # @param payload [Hash] JWT payload
      # @return [Interfaces::User] an user, whatever it is
      def self.find_user(payload)
        config = JWTAuth.config
        scope = payload['scp'].to_sym
        user_repo = config.mappings[scope]
        user_repo.find_for_jwt_authentication(payload['sub'])
      end

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

      # Returns the payload to encode for a given user in a scope
      #
      # @param user [Interfaces::User] an user, whatever it is
      # @param scope [Symbol] A Warden scope
      # @return [Hash] payload to encode
      def self.payload_for_user(user, scope)
        sub = user.jwt_subject
        payload = { 'sub' => String(sub), 'scp' => scope.to_s }
        return payload unless user.respond_to?(:jwt_payload)

        user.jwt_payload.merge(payload)
      end
    end
  end
end
