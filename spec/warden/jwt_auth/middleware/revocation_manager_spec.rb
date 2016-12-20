# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware::RevocationManager do
  include_context 'configuration'
  include_context 'fixtures'
  include_context 'middleware'

  let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user) }
  let(:payload) { Warden::JWTAuth::TokenDecoder.new.call(token) }

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
    it 'adds ENV_KEY key to env' do
      get '/'

      expect(last_request.env[described_class::ENV_KEY]).to eq(true)
    end

    context 'when PATH_INFO matches with configured' do
      it 'calls revocation strategy with decoded payload and user' do
        sign_in_with_jwt

        expect(
          revocation_strategy
        ).to receive(:revoke).with(payload, user)

        get('/sign_out')
      end
    end

    context 'when PATH_INFO does not match with configured' do
      it 'does not call the revocation strategy' do
        sign_in_with_jwt

        expect(
          revocation_strategy
        ).not_to receive(:revoke)

        get '/another_request'
      end
    end

    context 'when token is not present in request headers' do
      it 'does not call the revocation strategy' do
        login_as user, scope: :user

        expect(
          revocation_strategy
        ).not_to receive(:revoke).with(payload, user)

        get('/sign_out')
      end
    end
  end
end
