# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Warden::JWTAuth::Middleware::RevocationManager do
  include_context 'configuration'
  include_context 'fixtures'
  include_context 'middleware'

  let(:token_payload) { Warden::JWTAuth::UserEncoder.new.call(user, :user, 'aud') }
  let(:token) { token_payload[0] }
  let(:payload) { token_payload[1] }

  let(:this_app) { described_class.new(dummy_app) }
  let(:app) { warden_app(this_app) }

  def sign_in_with_jwt
    header('Authorization', "Bearer #{token}")
    login_as(user, scope: :user)
  end

  describe '::ENV_KEY' do
    it 'is warden-jwt_auth.revocation_manager' do
      expect(
        described_class::ENV_KEY
      ).to eq('warden-jwt_auth.revocation_manager')
    end
  end

  describe '#call(env)' do
    let(:revocation_strategy) { revocation_strategies[:user] }

    it 'adds ENV_KEY key to env' do
      get '/'

      expect(last_request.env[described_class::ENV_KEY]).to eq(true)
    end

    context 'when path and method match' do
      it 'revokes the token' do
        sign_in_with_jwt
        delete '/sign_out'

        expect(revocation_strategy.jwt_revoked?(payload, user)).to eq(true)
      end
    end

    context 'when path does not match' do
      it 'does not call the revocation strategy' do
        sign_in_with_jwt
        delete '/another_request'

        expect(revocation_strategy.jwt_revoked?(payload, user)).to eq(false)
      end
    end

    context 'when verb does not match' do
      it 'does not call the revocation strategy' do
        sign_in_with_jwt
        post '/sign_out'

        expect(revocation_strategy.jwt_revoked?(payload, user)).to eq(false)
      end
    end

    context 'when token is not present in request headers' do
      it 'does not call the revocation strategy' do
        login_as user, scope: :user
        delete '/sign_out'
        sign_in_with_jwt

        expect(revocation_strategy.jwt_revoked?(payload, user)).to eq(false)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
