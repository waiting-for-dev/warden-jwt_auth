# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'warden/jwt_auth'
require 'pry-byebug'
require 'simplecov'

SimpleCov.start

SPEC_ROOT = Pathname(__FILE__).dirname

Dir[SPEC_ROOT.join('support/**/*.rb')].each do |file|
  require file
end
