# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware do
  include Rack::Test::Methods

  include_context 'configuration'

  let(:dummy_app) { ->(_env) { [200, {}, []] } }
  let(:this_app) { described_class.new(dummy_app) }

  describe '#call(env)' do
    let(:app) { Warden::Manager.new(this_app) }

    before do
      get '/'
    end

    it 'calls TokenDispatcher middleware' do
      env_key = Warden::JWTAuth::Middleware::TokenDispatcher::ENV_KEY

      expect(last_request.env[env_key]).to eq(true)
    end

    it 'calls BlacklistManager middleware' do
      env_key = Warden::JWTAuth::Middleware::BlacklistManager::ENV_KEY

      expect(last_request.env[env_key]).to eq(true)
    end
  end
end
