# frozen_string_literal: true

require 'dry/configurable'
require 'jwt'
require 'warden'
require 'warden/jwt_auth/version'
require 'warden/jwt_auth/header_parser'
require 'warden/jwt_auth/user_coder'
require 'warden/jwt_auth/token_coder'
require 'warden/jwt_auth/hooks'
require 'warden/jwt_auth/strategy'
require 'warden/jwt_auth/middleware'

module Warden
  # JWT authentication plugin for warden.
  #
  # It consists of a strategy which tries to authenticate an user decoding a
  # token present in the `Authentication` header (as `Bearer #{token}`).
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

    # A hash of warden scopes as keys and user repositories as values.
    #
    # User repositories must respond to:
    #
    # * `find_for_jwt_authentication(sub)` which takes `sub` claim as argument
    # and must return user instances.
    #
    # An user instance must respond to two methods:
    #
    # * `jwt_subject` must return what will be encoded as `sub` claim *
    # * `jwt_payload` must return a JWT payload that will be merged with the
    # default
    #
    # @example
    #   setting :mappings, { user: User }
    #
    #   #...
    #
    #   user = User.find_for_jwt_authentication(1)
    #   user.jwt_subject # => 1
    #   user.jwt_payload # => { 'foo' => 'bar' }
    setting :mappings, {}

    # Regular expression to match request paths where a JWT token should be
    # added to the `Authorization` response header
    setting :dispatch_paths, nil

    # Regular expression to match request paths where incoming JWT token should
    # be revoked
    setting :revocation_paths, nil

    # Strategy to revoke tokens. It must respond to two methods:
    #
    # * `revoke(payload, user)` must implement the logic to revoke given payload
    # for given user
    # * `revoked?(payload, user)` must implement the logic to check whether
    # given payload is revoked for given user
    setting :revocation_strategy
  end
end
