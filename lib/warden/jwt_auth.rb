# frozen_string_literal: true

require 'dry/configurable'
require 'warden/jwt_auth/version'
require 'warden/jwt_auth/header_parser'
require 'warden/jwt_auth/token_coder'
require 'warden/jwt_auth/strategy'
require 'warden/jwt_auth/middleware'

module Warden
  # JWT authentication plugin for warden
  module JWTAuth
    extend Dry::Configurable

    setting :secret
    setting :expiration_time, 3600 * 24 * 365
    setting :blacklist
    setting :mappings
    setting :response_token_paths, /\b\B/
    setting :blacklist_token_paths, /\b\B/
  end
end
