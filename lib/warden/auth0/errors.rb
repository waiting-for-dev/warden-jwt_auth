# frozen_string_literal: true

module Warden
  module Auth0
    module Errors
      # Error raised when trying to decode a token that has been revoked for an
      # user
      class RevokedToken < JWT::DecodeError
      end

      # Error raised when no issuer has been configured
      class NoConfiguredIssuer < JWT::DecodeError
      end

      # Error raised when no aud has been configured
      class NoConfiguredAud < JWT::DecodeError
      end

      # Error raised when the user decoded from a token is nil
      class NilUser < JWT::DecodeError
      end

      # Error raised when trying to decode a token whose "issuer" does not match the expected one
      class WrongIssuer < JWT::DecodeError
      end

      # Error raised when trying to decode a token for an scope that doesn't
      # match the one encoded in the payload
      class WrongScope < JWT::DecodeError
      end

      # Error raised when trying to decode a token which `aud` claim does not
      # match with the expected one
      class WrongAud < JWT::DecodeError
      end
    end
  end
end
