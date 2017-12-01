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

    # The secret used to encode the token
    setting :secret

    # Expiration time for tokens
    setting :expiration_time, 3600

    # A hash of warden scopes as keys and user repositories as values. The
    # values can be either the constants themselves or the constant names.
    #
    # @see Interfaces::UserRepository
    # @see Interfaces::User
    setting(:mappings, {}) do |value|
      symbolize_keys(value)
    end

    # Array of tuples [request_method, request_path_regex] to match request
    # verbs and paths where a JWT token should be added to the `Authorization`
    # response header
    #
    # @example
    #  [
    #    ['POST', %r{^/sign_in$}]
    #  ]
    setting(:dispatch_requests, []) do |value|
      upcase_first_items(value)
    end

    # Array of tuples [request_method, request_path_regex] to match request
    # verbs and paths where incoming JWT token should be be revoked
    #
    # @example
    #  [
    #    ['DELETE', %r{^/sign_out$}]
    #  ]
    setting :revocation_requests, [] do |value|
      upcase_first_items(value)
    end

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
    setting(:revocation_strategies, {}) do |value|
      symbolize_keys(value)
    end

    # :reek:UtilityFunction
    def self.symbolize_keys(hash)
      Hash[
        hash.each_pair do |key, value|
          [key.to_sym, value]
        end
      ]
    end

    # :reek:UtilityFunction
    def self.upcase_first_items(array)
      array.map do |tuple|
        method, path = tuple
        [method.to_s.upcase, path]
      end
    end

    Import = Dry::AutoInject(config)

    config.instance_eval do
      def mappings
        constantize_values(super)
      end

      def revocation_strategies
        constantize_values(super)
      end

      # :reek:UtilityFunction
      def constantize_values(hash)
        hash.each_with_object({}) do |(key, value), memo|
          memo[key] = value.is_a?(String) ? Object.const_get(value) : value
        end
      end
    end
  end
end

require 'warden/jwt_auth/version'
require 'warden/jwt_auth/header_parser'
require 'warden/jwt_auth/payload_user_helper'
require 'warden/jwt_auth/user_encoder'
require 'warden/jwt_auth/user_decoder'
require 'warden/jwt_auth/token_encoder'
require 'warden/jwt_auth/token_decoder'
require 'warden/jwt_auth/token_revoker'
require 'warden/jwt_auth/hooks'
require 'warden/jwt_auth/strategy'
require 'warden/jwt_auth/middleware'
require 'warden/jwt_auth/interfaces'
