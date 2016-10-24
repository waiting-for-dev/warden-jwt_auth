# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware::TokenDispatcher do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  include_context 'configuration'

  before { config.response_token_paths = '/sign_in' }

  let(:dummy_app) { ->(_env) { [200, {}, []] } }
  let(:this_app) { described_class.new(dummy_app, config) }
  let(:app) { Warden::Manager.new(this_app) }

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

    context 'when PATH_INFO matches configured response_token_paths' do
      it 'adds token to the response' do
        login_as Fixtures.user

        get '/sign_in'

        expect(last_response.headers['Authorization']).not_to be_nil
      end
    end

    context 'when PATH_INFO does not match configured response_token_paths' do
      it 'adds nothing to the response' do
        login_as Fixtures.user

        get '/another_path'

        expect(last_response.headers['Authorization']).to be_nil
      end
    end
  end

  after { Warden.test_reset! }
end
