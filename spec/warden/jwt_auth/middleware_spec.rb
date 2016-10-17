# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  before do
    Warden::JWTAuth.configure do |config|
      config.secret = '123'
      config.blacklist = []
      config.response_token_paths = '/sign_in'
      config.blacklist_token_paths = '/sign_out'
    end
  end

  let(:config) { Warden::JWTAuth.config }
  let(:pristine_app) { ->(_env) { [200, {}, []] } }
  let(:warden_app) { Warden::Manager.new(pristine_app) }
  let(:app) { described_class.new(warden_app) }
  let(:user) do
    Class.new do
      def jwt_subject
        1
      end
    end
  end
  let(:token) do
    Warden::JWTAuth::TokenCoder.encode(
      { sub: user.new.jwt_subject }, config
    )
  end

  describe '#call(env)' do
    it 'calls TokenDispatcher middleware' do
      login_as user.new
      get '/sign_in'

      expect(last_response.headers['Authorization']).not_to be_nil
    end

    it 'calls BlacklistManager middleware' do
      jti = Warden::JWTAuth::TokenCoder.decode(token, config)['jti']
      header('Authorization', "Bearer #{token}")

      get '/sign_out'

      expect(config.blacklist.member?(jti)).to eq(true)
    end
  end

  after { Warden.test_reset! }
end
