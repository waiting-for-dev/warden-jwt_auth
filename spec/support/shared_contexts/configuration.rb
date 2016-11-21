# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::JWTAuth.configure do |config|
      config.secret = '123'
      config.response_token_paths = %r{^/sign_in$}
      config.token_revocation_paths = %r{^/sign_out$}
      config.revocation_strategy = Fixtures::RevocationStrategy.new
      config.mappings = { user: Fixtures::UserRepo }
    end
  end

  let(:config) { Warden::JWTAuth.config }
  let(:secret) { config.secret }
  let(:response_token_paths) { config.response_token_paths }
  let(:token_revocation_paths) { config.token_revocation_paths }
  let(:revocation_strategy) { config.revocation_strategy }
  let(:mappings) { config.mappings }
  let(:expiration_time) { config.expiration_time }
end
