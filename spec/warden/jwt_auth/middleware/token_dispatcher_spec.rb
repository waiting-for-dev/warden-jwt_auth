# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware::TokenDispatcher do
  include_context 'configuration'
  include_context 'fixtures'
  include_context 'middleware'

  let(:this_app) { described_class.new(dummy_app) }
  let(:app) { warden_app(this_app) }

  describe '::ENV_KEY' do
    it 'is warden-jwt_auth.token_dispatcher' do
      expect(
        described_class::ENV_KEY
      ).to eq('warden-jwt_auth.token_dispatcher')
    end
  end

  describe '#call(env)' do
    it 'adds ENV_KEY key to env' do
      get '/'

      expect(last_request.env[described_class::ENV_KEY]).to eq(true)
    end

    context 'when token has been added to env' do
      it 'adds it to the Authorization header' do
        login_as user, scope: :user

        post '/sign_in'

        expect(last_response.headers['Authorization']).not_to be_nil
      end
    end

    context 'when token has not been added to env' do
      it 'adds nothing to the Authorization header' do
        post '/sign_in'

        expect(last_response.headers['Authorization']).to be_nil
      end
    end
  end
end
