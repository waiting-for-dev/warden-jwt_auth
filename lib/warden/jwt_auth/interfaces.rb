# frozen_string_literal: true

module Warden
  module JWTAuth
    # Interfaces expected to be implemented in applications working with this
    # gem
    module Interfaces
      # Repository that returns [User]
      class UserRepository
        # Finds and returns an [User]
        #
        # @param _sub [String] JWT sub claim
        # @return [User]
        def find_for_jwt_authentication(_sub)
          raise NotImplementedError
        end
      end

      # An user
      class User
        # What will be encoded as `sub` claim. It must respond to `#to_s`.
        #
        # @return [#to_s] `sub` claim
        def jwt_subject
          raise NotImplementedError
        end

        # Allows adding extra claims to be encoded within the payload
        #
        # @return [Hash] claims to be merged with defaults
        def jwt_payload
          {}
        end

        # Does something just after a JWT for the user has been dispatched.
        #
        # @param _token [String]
        # @param _payload [Hash]
        def on_jwt_dispatch(_token, _payload)
          raise NotImplementedError
        end
      end

      # Strategy to manage JWT revocation
      class RevocationStrategy
        # Does something to revoke a JWT payload
        #
        # @param _payload [Hash]
        # @param _user [User]
        def revoke_jwt(_payload, _user)
          raise NotImplementedError
        end

        # Returns whether a JWT payload is revoked
        #
        # @param _payload [Hash]
        # @param _user [User]
        # @return [Boolean]
        def jwt_revoked?(_payload, _user)
          raise NotImplementedError
        end
      end
    end
  end
end
