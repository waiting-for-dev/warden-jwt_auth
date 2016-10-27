# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware::BlacklistManager do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  include_context 'configuration'
  include_context 'blacklist'

  let(:user) { Fixtures.user }
  let(:token) { Warden::JWTAuth::TokenCoder.encode(user.jwt_subject, config) }
  let(:jti) { Warden::JWTAuth::TokenCoder.decode(token, config)['jti'] }

  let(:dummy_app) { ->(_env) { [200, {}, []] } }
  let(:this_app) { described_class.new(dummy_app, config) }
  let(:app) { Warden::Manager.new(this_app) }

  describe '::ENV_KEY' do
    it 'is warden-jwt_auth.blacklist_manager' do
      expect(
        described_class::ENV_KEY
      ).to eq('warden-jwt_auth.blacklist_manager')
    end
  end

  describe '#call(env)' do
    it 'adds ENV_KEY key to env' do
      get '/'

      expect(last_request.env[described_class::ENV_KEY]).to eq(true)
    end

    context 'when PATH_INFO matches configured blacklist_token_paths' do
      it 'adds token to the blacklist when user is logged in' do
        # Eager load or it will be unaccessible once in the blacklist
        jti

        header('Authorization', "Bearer #{token}")
        login_as user
        get '/sign_out'

        expect(blacklist.member?(jti)).to eq(true)
      end

      it 'does not add token to the blacklist when user is not logged in' do
        header('Authorization', "Bearer #{token}")
        get '/sign_out'

        expect(blacklist.member?(jti)).to eq(false)
      end
    end

    context 'when PATH_INFO does not match configured blacklist_token_paths' do
      it 'does not add token to the blacklist' do
        header('Authorization', "Bearer #{token}")
        login_as user
        get '/another_request'

        expect(blacklist.member?(jti)).to eq(false)
      end
    end
  end
end
