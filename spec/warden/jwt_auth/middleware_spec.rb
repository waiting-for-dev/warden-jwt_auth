# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Middleware do
  include_context 'configuration'
  include_context 'middleware'

  describe '#call(env)' do
    let(:app) { described_class.new(dummy_app) }

    before { get '/' }

    it 'adds TokenDispatcher middleware' do
      env_key = Warden::JWTAuth::Middleware::TokenDispatcher::ENV_KEY

      expect(last_request.env[env_key]).to eq(true)
    end

    it 'adds RevocationManager middleware' do
      env_key = Warden::JWTAuth::Middleware::RevocationManager::ENV_KEY

      expect(last_request.env[env_key]).to eq(true)
    end
  end
end
