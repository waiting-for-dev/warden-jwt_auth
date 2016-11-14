# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware::RevocationManager do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  include_context 'configuration'
  include_context 'revocation'

  let(:user) { Fixtures::User.new }
  let(:token) { Warden::JWTAuth::TokenCoder.encode(user.jwt_subject, config) }
  let(:payload) { Warden::JWTAuth::TokenCoder.decode(token, config) }

  let(:dummy_app) { ->(_env) { [200, {}, []] } }
  let(:this_app) { described_class.new(dummy_app, config) }
  let(:app) { Warden::Manager.new(this_app) }

  def sign_in
    header('Authorization', "Bearer #{token}")
    login_as(user)
  end

  describe '::ENV_KEY' do
    it 'is warden-jwt_auth.revocation_manager' do
      expect(
        described_class::ENV_KEY
      ).to eq('warden-jwt_auth.revocation_manager')
    end
  end

  describe '#call(env)' do
    before do
      allow(
        config.revocation_strategy
      ).to receive(:revoke).with(payload)
    end

    it 'adds ENV_KEY key to env' do
      get '/'

      expect(last_request.env[described_class::ENV_KEY]).to eq(true)
    end

    context 'when PATH_INFO matches configured revocation_token_paths' do
      it 'calls the revocation strategy when user is logged in' do
        sign_in

        get('/sign_out')

        expect(
          config.revocation_strategy
        ).to have_received(:revoke).with(payload)
      end

      it 'does not call the revocation strategy when user is not logged in' do
        get '/sign_out'

        expect(
          config.revocation_strategy
        ).not_to have_received(:revoke)
      end
    end

    context 'when PATH_INFO does not match configured token_revocation_paths' do
      it 'does not call the revocation strategy' do
        sign_in

        get '/another_request'

        expect(
          config.revocation_strategy
        ).not_to have_received(:revoke)
      end
    end
  end
end
