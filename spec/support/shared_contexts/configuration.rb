# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::JWTAuth.configure do |config|
      config.secret = '123'
      config.dispatch_paths = [['POST', %r{^/sign_in$}]]
      config.revocation_paths = [['DELETE', %r{^/sign_out$}]]
      config.revocation_strategy = Fixtures::RevocationStrategy.new
      config.mappings = { user: Fixtures::UserRepo }
    end
  end

  let(:config) { Warden::JWTAuth.config }
  let(:secret) { config.secret }
  let(:dispatch_paths) { config.dispatch_paths }
  let(:revocation_paths) { config.revocation_paths }
  let(:revocation_strategy) { config.revocation_strategy }
  let(:mappings) { config.mappings }
  let(:expiration_time) { config.expiration_time }
end
