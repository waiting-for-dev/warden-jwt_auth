# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::JWTAuth.configure do |config|
      config.secret = '123'
      config.dispatch_requests = [['POST', %r{^/sign_in$}]]
      config.revocation_requests = [['DELETE', %r{^/sign_out$}]]
      config.revocation_strategy = Fixtures::RevocationStrategy.new
      config.mappings = { user: Fixtures::UserRepo }
    end
  end

  let(:config) { Warden::JWTAuth.config }
  let(:secret) { config.secret }
  let(:dispatch_requests) { config.dispatch_requests }
  let(:revocation_requests) { config.revocation_requests }
  let(:revocation_strategy) { config.revocation_strategy }
  let(:mappings) { config.mappings }
  let(:expiration_time) { config.expiration_time }
end
