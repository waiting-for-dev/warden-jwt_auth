# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'warden/jwt_auth'
require 'pry-byebug'
require 'simplecov'

SimpleCov.start

SPEC_ROOT = Pathname(__FILE__).dirname

Dir[SPEC_ROOT.join('support/**/*.rb')].sort.each do |file|
  require file
end
