# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware::BlacklistManager do
  include Rack::Test::Methods

  before do
    Warden::JWTAuth.configure do |config|
      config.secret = '123'
      config.blacklist = []
      config.blacklist_token_paths = '/sign_out'
    end
  end

  let(:config) { Warden::JWTAuth.config }
  let(:pristine_app) { ->(_env) { [200, {}, []] } }
  let(:app) { described_class.new(pristine_app, config) }
  let(:user) do
    Class.new do
      def jwt_subject
        1
      end
    end
  end

  describe '#call(env)' do
    let(:token) do
      Warden::JWTAuth::TokenCoder.encode({ sub: user.new.jwt_subject }, config)
    end

    context 'when PATH_INFO matches configured blacklist_token_paths' do
      it 'adds token to the blacklist' do
        jti = Warden::JWTAuth::TokenCoder.decode(token, config)['jti']
        header('Authorization', "Bearer #{token}")

        get '/sign_out'

        expect(config.blacklist.member?(jti)).to eq(true)
      end
    end

    context 'when PATH_INFO does not match configured blacklist_token_paths' do
      it 'does not add token to the blacklist' do
        jti = Warden::JWTAuth::TokenCoder.decode(token, config)['jti']
        header('Authorization', "Bearer #{token}")

        get '/another_request'

        expect(config.blacklist.member?(jti)).to eq(false)
      end
    end
  end
end
