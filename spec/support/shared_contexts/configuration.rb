# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::Auth0.configure do |config|
      config.decoding_secret = 'useauth0byoktatobuildyourcustomidentitypipeline'
      config.issuer = 'https://test-dev.eu.auth0.com/'
      config.token_header = 'Authorization'
      config.user_resolver = ->(token) { Fixtures::User.instance }
    end
  end

  let(:config) { Warden::Auth0.config }
  let(:decoding_secret) { config.decoding_secret }
  let(:token_header) { config.token_header}
  let(:issuer) { config.issuer }
  let(:env_token_header) { ('HTTP_' + config.token_header.upcase).tr('-', '_') }
  let(:mappings) { config.mappings }
end
