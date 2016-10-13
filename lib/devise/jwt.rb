# frozen_string_literal: true

require 'devise/jwt/version'
require 'devise/jwt/token_coder'
require 'jwt'
require 'dry/configurable'

module Devise
  # JWT authentication plugin for devise
  module Jwt
    extend Dry::Configurable

    setting :secret
    setting :expiration_time, 3600 * 24 * 365
  end
end
