# frozen_string_literal: true

require 'dry/configurable'
require 'dry/auto_inject'
require 'jwt'
require 'warden'

module Warden
  # JWT authentication plugin for warden.
  #
  # It consists of a strategy which tries to authenticate an user decoding a
  # token present in the `Authentication` header (as `Bearer %token%`).
  # From it, it takes the `sub` claim and provides it to a configured repository
  # of users for the current scope.
  #
  # It also consists of two rack middlewares which perform two actions for
  # configured request paths: dispatching a token for a signed in user and
  # revoking an incoming token.
  module JWTAuth
    extend Dry::Configurable

    def symbolize_keys(hash)
      hash.transform_keys(&:to_sym)
    end

    def upcase_first_items(array)
      array.map do |tuple|
        method, path = tuple
        [method.to_s.upcase, path]
      end
    end

    def constantize_values(hash)
      hash.transform_values do |value|
        value.is_a?(String) ? Object.const_get(value) : value
      end
    end

    module_function :constantize_values, :symbolize_keys, :upcase_first_items

    # The secret used to encode the token
    setting :secret

    # The algorithm used to encode the token
    setting :algorithm, default: 'HS256'

    # Expiration time for tokens
    setting :expiration_time, default: 3600

    # Request header which value will be encoded as `aud` claim in JWT. If
    # the header is not present `aud` will be `nil`.
    setting :aud_header, default: 'JWT_AUD'

    # A hash of warden scopes as keys and user repositories as values. The
    # values can be either the constants themselves or the constant names.
    #
    # @see Interfaces::UserRepository
    # @see Interfaces::User
    setting(:mappings,
            default: {},
            constructor: ->(value) { constantize_values(symbolize_keys(value)) })

    # Array of tuples [request_method, request_path_regex] to match request
    # verbs and paths where a JWT token should be added to the `Authorization`
    # response header
    #
    # @example
    #  [
    #    ['POST', %r{^/sign_in$}]
    #  ]
    setting(:dispatch_requests,
            default: [],
            constructor: ->(value) { upcase_first_items(value) })

    # Array of tuples [request_method, request_path_regex] to match request
    # verbs and paths where incoming JWT token should be be revoked
    #
    # @example
    #  [
    #    ['DELETE', %r{^/sign_out$}]
    #  ]
    setting(:revocation_requests,
            default: [],
            constructor: ->(value) { upcase_first_items(value) })

    # Hash with scopes as keys and strategies to revoke tokens for that scope
    # as values. The values can be either the constants themselves or the
    # constant names.
    #
    # @example
    #  {
    #    user: UserRevocationStrategy
    #  }
    #
    # @see Interfaces::RevocationStrategy
    setting(:revocation_strategies,
            default: {},
            constructor: ->(value) { constantize_values(symbolize_keys(value)) })

    Import = Dry::AutoInject(config)
  end
end

require 'warden/jwt_auth/version'
require 'warden/jwt_auth/header_parser'
require 'warden/jwt_auth/payload_user_helper'
require 'warden/jwt_auth/env_helper'
require 'warden/jwt_auth/user_encoder'
require 'warden/jwt_auth/user_decoder'
require 'warden/jwt_auth/token_encoder'
require 'warden/jwt_auth/token_decoder'
require 'warden/jwt_auth/token_revoker'
require 'warden/jwt_auth/hooks'
require 'warden/jwt_auth/strategy'
require 'warden/jwt_auth/middleware'
require 'warden/jwt_auth/interfaces'
