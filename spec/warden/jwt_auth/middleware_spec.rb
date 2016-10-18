# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  include_context 'configuration'

  let(:pristine_app) { ->(_env) { [200, {}, []] } }
  let(:warden_app) { Warden::Manager.new(pristine_app) }
  let(:app) { described_class.new(warden_app) }

  describe '#call(env)' do
    it 'calls TokenDispatcher middleware' do
      env_key = Warden::JWTAuth::Middleware::TokenDispatcher::ENV_KEY

      get '/'

      expect(last_request.env[env_key]).to eq(true)
    end

    it 'calls BlacklistManager middleware' do
      env_key = Warden::JWTAuth::Middleware::BlacklistManager::ENV_KEY

      get '/'

      expect(last_request.env[env_key]).to eq(true)
    end
  end

  after { Warden.test_reset! }
end
