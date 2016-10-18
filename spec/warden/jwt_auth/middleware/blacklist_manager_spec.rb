# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware::BlacklistManager do
  include Rack::Test::Methods

  include_context 'configuration'
  include_context 'blacklist'

  let(:pristine_app) { ->(_env) { [200, {}, []] } }
  let(:app) { described_class.new(pristine_app, config) }

  describe '#call(env)' do
    let(:token) do
      Warden::JWTAuth::TokenCoder.encode(
        { sub: Fixtures.user.jwt_subject }, config
      )
    end

    context 'when PATH_INFO matches configured blacklist_token_paths' do
      it 'adds token to the blacklist' do
        jti = Warden::JWTAuth::TokenCoder.decode(token, config)['jti']
        header('Authorization', "Bearer #{token}")

        get '/sign_out'

        expect(blacklist.member?(jti)).to eq(true)
      end
    end

    context 'when PATH_INFO does not match configured blacklist_token_paths' do
      it 'does not add token to the blacklist' do
        jti = Warden::JWTAuth::TokenCoder.decode(token, config)['jti']
        header('Authorization', "Bearer #{token}")

        get '/another_request'

        expect(blacklist.member?(jti)).to eq(false)
      end
    end
  end
end
