# frozen_string_literal: true

require 'dry/configurable'
require 'devise/jwt/version'
require 'devise/jwt/token_coder'
require 'devise/jwt/strategy'

module Devise
  # JWT authentication plugin for devise
  module Jwt
    extend Dry::Configurable

    setting :secret
    setting :expiration_time, 3600 * 24 * 365
    setting :blacklist
    setting :mappings
  end
end
