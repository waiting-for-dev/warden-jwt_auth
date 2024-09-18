# frozen_string_literal: true

shared_context 'configuration' do
  before do
    Warden::Auth0.configure do |config|
      config.issuer = 'https://test-dev.eu.auth0.com/'
      config.aud = 'https://test.com/api'
      config.algorithm = "RS256"
      config.token_header = 'Authorization'
      config.jwks_url = "https://my-url.com/.well-known/jwks.json"
      config.jwks = {}
    end

    Warden::Strategies.add(:auth0, Warden::Auth0::Strategy) do
      def user_resolver(decoded_token)
        Fixtures::User.instance
      end
    end
  end

  let(:config) { Warden::Auth0.config }
  let(:token_header) { config.token_header}
  let(:issuer) { config.issuer }
  let(:env_token_header) { ('HTTP_' + config.token_header.upcase).tr('-', '_') }
end
