# frozen_string_literal: true

require 'spec_helper'

describe 'Authorization', type: :feature do
  include_context 'configuration'
  include_context 'fixtures'
  include_context 'feature'

  let(:app) { build_app(auth_app) }

  context 'when a valid token is provided' do
    it 'authenticates the user' do
      env = env_with_token(pristine_env, valid_token)

      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(200)
    end
  end

  context 'when provided token is not valid' do
    it 'does not authenticate the user' do
      token = '123'
      env = env_with_token(pristine_env, token)

      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(401)
    end
  end

  context 'when provided token is from another issuer' do
    it 'does not authenticate the user' do
      env = env_with_token(pristine_env, wrong_issuer_token)

      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(401)
    end
  end

  context 'when the user fetched from repo is nil' do
    before { Warden::Auth0.config.user_resolver = ->(_token) { nil } }

    after { Warden::Auth0.config.user_resolver = ->(_token) { Fixtures::User.instance } }

    it 'does not authenticate' do
      env = env_with_token(pristine_env, valid_token)

      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(401)
    end
  end
end
