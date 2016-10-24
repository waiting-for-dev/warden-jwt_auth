# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  include_context 'configuration'

  let(:dummy_app) { ->(_env) { [200, {}, []] } }
  let(:this_app) { described_class.new(dummy_app) }

  let(:token_env_key) { Warden::JWTAuth::Middleware::TokenDispatcher::ENV_KEY }
  let(:black_env_key) { Warden::JWTAuth::Middleware::BlacklistManager::ENV_KEY }

  describe '#call(env)' do
    context 'when warden middleware has not been called' do
      let(:app) { this_app }

      it 'raises a RuntimeError' do
        expect { get '/' }.to raise_error(RuntimeError)
      end
    end

    context 'when an user has been logged in' do
      let(:app) { Warden::Manager.new(this_app) }

      before do
        login_as Fixtures.user

        get '/'
      end

      it 'calls TokenDispatcher middleware' do
        expect(last_request.env[token_env_key]).to eq(true)
      end

      it 'calls BlacklistManager middleware' do
        expect(last_request.env[black_env_key]).to eq(true)
      end
    end

    context 'when an user has not been logged in' do
      let(:app) { Warden::Manager.new(this_app) }

      before { get '/' }

      it 'does not call TokenDispatcher midleware' do
        expect(last_request.env[token_env_key]).to be_nil
      end

      it 'does not call BlacklistManager midleware' do
        expect(last_request.env[black_env_key]).to be_nil
      end
    end
  end

  after { Warden.test_reset! }
end
