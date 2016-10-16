# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Devise::Jwt::Middleware::BlacklistManager do
  include Rack::Test::Methods

  before do
    Devise::Jwt.configure do |config|
      config.secret = '123'
      config.blacklist = []
      config.blacklist_token_paths = '/sign_out'
    end
  end

  let(:config) { Devise::Jwt.config }
  let(:pristine_app) { ->(_env) { [200, {}, []] } }
  let(:app) { described_class.new(pristine_app, config) }
  let(:user) do
    Class.new do
      def id
        1
      end
    end
  end

  describe '#call(env)' do
    it 'adds token to the blacklist' do
      token = Devise::Jwt::TokenCoder.encode({ sub: user.new.id }, config)
      jti = Devise::Jwt::TokenCoder.decode(token, config)['jti']
      header('Authorization', "Bearer #{token}")

      get '/sign_out'

      expect(config.blacklist.member?(jti)).to eq(true)
    end
  end

  context 'when PATH_INFO does not match configured blacklist_token_paths' do
    it 'does not add token to the blacklist' do
      token = Devise::Jwt::TokenCoder.encode({ sub: user.new.id }, config)
      jti = Devise::Jwt::TokenCoder.decode(token, config)['jti']
      header('Authorization', "Bearer #{token}")

      get '/another_request'

      expect(config.blacklist.member?(jti)).to eq(false)
    end
  end
end
