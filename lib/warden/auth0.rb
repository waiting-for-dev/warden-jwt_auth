# frozen_string_literal: true

require 'dry/configurable'
require 'dry/auto_inject'
require 'jwt'
require 'warden'

module Warden
  # Auth0 authentication plugin for warden.
  #
  # It consists of a strategy which tries to authenticate an user decoding a
  # token present in the `Authentication` header (as `Bearer %token%`).
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

    # The algorithm used to encode the token
    setting :algorithm

    # The issuer claims associated with the tokens
    #
    # Will be used to only apply the warden strategy when the issuer matches.
    # This allows for multiple token issuers being used.
    # @see https://datatracker.ietf.org/doc/html/rfc7519#section-4.1.1
    setting :issuer, default: nil

    # The aud claims associated with the tokens
    #
    # Will be used to only apply the warden strategy when the audience matches.
    setting :aud, default: nil

    setting :user_resolver

    Import = Dry::AutoInject(config)
  end
end

require 'warden/auth0/version'
require 'warden/auth0/errors'
require 'warden/auth0/header_parser'
require 'warden/auth0/env_helper'
require 'warden/auth0/token_decoder'
require 'warden/auth0/strategy'
