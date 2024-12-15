# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::JWTAuth.configure do |config|
      config.secret = '123'
      config.rotation_secret = '456'
      config.decoding_secret = '123'
      config.algorithm = 'HS256'
      config.dispatch_requests = [['POST', %r{^/sign_in$}]]
      config.revocation_requests = [['DELETE', %r{^/sign_out$}]]
      config.revocation_strategies = { user: Fixtures::RevocationStrategy.new }
      config.mappings = { user: Fixtures::UserRepo }
      config.token_header = 'Authorization'
      config.aud_header = 'TEST_AUD'
      config.issuer = 'http://example.com'
    end
  end

  let(:config) { Warden::JWTAuth.config }
  let(:secret) { config.secret }
  let(:rotation_secret) { config.rotation_secret }
  let(:decoding_secret) { config.decoding_secret }
  let(:algorithm) { config.algorithm }
  let(:dispatch_requests) { config.dispatch_requests }
  let(:revocation_requests) { config.revocation_requests }
  let(:revocation_strategies) { config.revocation_strategies }
  let(:mappings) { config.mappings }
  let(:expiration_time) { config.expiration_time }
  let(:token_header) { config.token_header}
  let(:env_token_header) { ('HTTP_' + config.token_header.upcase).tr('-', '_') }
  let(:aud_header) { config.aud_header }
  let(:env_aud_header) { ('HTTP_' + config.aud_header.upcase).tr('-', '_') }
end
