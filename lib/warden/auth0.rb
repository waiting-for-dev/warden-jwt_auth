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
  module Auth0
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

    # The secret used to decode the token, defaults to `secret` if not provided
    setting :decoding_secret, constructor: ->(value) { value || config.secret }

    # Request header that will be used for receiving and returning the token.
    setting :token_header, default: 'Authorization'

    # The issuer claims associated with the tokens
    #
    # Will be used to only apply the warden strategy when the issuer matches.
    # This allows for multiple token issuers being used.
    # @see https://datatracker.ietf.org/doc/html/rfc7519#section-4.1.1
    setting :issuer, default: nil

    Import = Dry::AutoInject(config)
  end
end

require 'warden/auth0/version'
require 'warden/auth0/header_parser'
require 'warden/auth0/payload_user_helper'
require 'warden/auth0/env_helper'
require 'warden/auth0/user_decoder'
require 'warden/auth0/token_decoder'
require 'warden/auth0/strategy'
require 'warden/auth0/interfaces'
