# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warden/jwt_auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'warden-jwt_auth'
  spec.version       = Warden::JWTAuth::VERSION
  spec.authors       = ['Marc Busqué']
  spec.email         = ['marc@lamarciana.com']

  spec.summary       = 'JWT authentication for Warden.'
  spec.description   = 'JWT authentication for Warden, ORM agnostic and accepting the implementation of token revocation strategies.'
  spec.homepage      = 'https://github.com/waiting-for-dev/warden-jwt_auth'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_dependency 'dry-auto_inject', '>= 0.8', '< 2'
  spec.add_dependency 'dry-configurable', '>= 0.13', '< 2'
  spec.add_dependency 'jwt', '~> 2.1'
  spec.add_dependency 'warden', '~> 1.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry-byebug', '~> 3.7'
  spec.add_development_dependency 'rack-test', '~> 1.1'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.8'
  # Cops
  spec.add_development_dependency 'rubocop', '~> 0.87'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.42'
  # Test reporting
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  spec.add_development_dependency 'simplecov', '0.17'
end
