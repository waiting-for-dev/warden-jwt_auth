# frozen_string_literal: true

require 'spec_helper'

describe Warden::Auth0::UserDecoder do
  include_context 'configuration'
  include_context 'fixtures'

  let(:token) { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJqdGkiOiJiYWYxZGMzOC0wMzMxLTQwZDMtYjgwYS02MGZkMmM1YTIxYzMiLCJpc3MiOiJodHRwczovL3Rlc3QtZGV2LmV1LmF1dGgwLmNvbS8ifQ.bohJzH8dseepETezDOs3uX6oJcwJvhQwMyWnmO8OY4E' }
  let(:issuer) { 'https://test-dev.eu.auth0.com/' }
  let(:payload) do
    {
      sub => '1234567890',
      name => 'John Doe',
      iat => 1516239022,
      jti => 'baf1dc38-0331-40d3-b80a-60fd2c5a21c3',
      iss => issuer
    }
  end

  let(:decoded_user) { user }

  before do
    Warden::Auth0.config.user_resolver = ->(_token) { decoded_user }
  end

  describe '#call(token, scope, aud)' do
    it 'returns encoded user' do
      expect(
        described_class.new.call(token, issuer)
      ).to eq(user)
    end

    context 'when no user is found' do
      let(:decoded_user) { nil }

      it 'raises NilUser' do
        expect do
          described_class.new.call(token, issuer)
        end.to raise_error(Warden::Auth0::Errors::NilUser)
      end
    end

    context 'when the iss claim does not match the intended one' do
      it 'raises WrongIssuer if iss claim does not match with intended one' do
        expect do
          described_class.new.call(token, "https://wrong.eu.auth0.com/")
        end.to raise_error(Warden::Auth0::Errors::WrongIssuer)
      end
    end
  end
end
