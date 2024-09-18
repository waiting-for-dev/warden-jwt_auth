# frozen_string_literal: true

require 'dry/configurable'
require 'dry/auto_inject'
require 'jwt'
require 'warden'
require 'faraday'

module Warden
  # Auth0 authentication plugin for warden.
  #
  # It consists of a strategy which tries to authenticate an user decoding a
  # token present in the `Authentication` header (as `Bearer %token%`).
  module Auth0
    extend Dry::Configurable
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

    # The url to fetch jwks from
    setting :jwks_url

    # Store the JWKS after fetching it
    setting :jwks, constructor: ->(jwks) { jwks || fetch_jwks(config.jwks_url) }

    Import = Dry::AutoInject(config)

    # Method to fetch JWKS from the specified URL
    def self.fetch_jwks(jwks_url)
      raise 'No url provided for fetching jwks' if jwks_url.nil?

      jwks_response = connection.get(jwks_url).body
      jwks = JWT::JWK::Set.new(jwks_response)
      jwks.select { |key| key[:use] == 'sig' }
    rescue StandardError => e
      raise "Failed to fetch JWKS: #{e.message}"
    end

    def self.connection
      Faraday.new(request: { timeout: 5 }) do |conn|
        conn.response :json
      end
    end
  end
end

require 'warden/auth0/version'
require 'warden/auth0/errors'
require 'warden/auth0/header_parser'
require 'warden/auth0/env_helper'
require 'warden/auth0/token_decoder'
require 'warden/auth0/strategy'
