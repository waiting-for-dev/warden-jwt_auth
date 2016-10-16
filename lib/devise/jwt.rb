# frozen_string_literal: true

require 'dry/configurable'
require 'devise/jwt/version'
require 'devise/jwt/token_coder'
require 'devise/jwt/strategy'
require 'devise/jwt/middleware'

module Devise
  # JWT authentication plugin for devise
  module Jwt
    extend Dry::Configurable

    setting :secret
    setting :expiration_time, 3600 * 24 * 365
    setting :blacklist
    setting :mappings
    setting :response_token_paths, /\b\B/
  end
end
