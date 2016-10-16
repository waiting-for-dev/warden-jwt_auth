# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Devise::Jwt::Middleware do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  before do
    Devise::Jwt.configure do |config|
      config.secret = '123'
      config.blacklist = []
      config.response_token_paths = '/sign_in'
      config.blacklist_token_paths = '/sign_out'
    end
  end

  let(:config) { Devise::Jwt.config }
  let(:pristine_app) { ->(_env) { [200, {}, []] } }
  let(:warden_app) { Warden::Manager.new(pristine_app) }
  let(:app) { described_class.new(warden_app) }
  let(:user) do
    Class.new do
      def id
        1
      end
    end
  end

  describe '#call(env)' do
    it 'calls TokenDispatcher middleware' do
      login_as user.new
      get '/sign_in'

      expect(last_response.headers['Authorization']).not_to be_nil
    end

    it 'calls BlacklistManager middleware' do
      token = Devise::Jwt::TokenCoder.encode({ sub: user.new.id }, config)
      jti = Devise::Jwt::TokenCoder.decode(token, config)['jti']
      header('Authorization', "Bearer #{token}")

      get '/sign_out'

      expect(config.blacklist.member?(jti)).to eq(true)
    end
  end

  after { Warden.test_reset! }
end
