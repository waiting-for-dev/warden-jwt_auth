# frozen_string_literal: true

require 'spec_helper'

describe 'Authorization', type: :feature do
  include_context 'configuration'
  include_context 'fixtures'
  include_context 'feature'

  let(:app) { build_app(auth_app) }

  context 'when a valid token is provided' do
    it 'authenticates the user' do
      token = generate_token(user, :user, pristine_env)
      env = env_with_token(pristine_env, token)

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

  context 'when provided token has been revoked' do
    it 'does not authenticate the user' do
      token = generate_token(user, :user, pristine_env)
      env = env_with_token(pristine_env, token)

      call_app(app, env, ['DELETE', '/sign_out'])
      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(401)
    end
  end

  context 'when provided token is from another scope' do
    it 'does not authenticate the user' do
      token = generate_token(user, :unknown, pristine_env)
      env = env_with_token(pristine_env, token)

      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(401)
    end
  end

  context 'when the user fetched from repo is nil' do
    before { Warden::JWTAuth.config.mappings = { user: nil_user_repo } }

    it 'does not authenticate' do
      token = generate_token(user, :user, pristine_env)
      env = env_with_token(pristine_env, token)

      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(401)
    end

    after { Warden::JWTAuth.config.mappings = { user: user_repo } }
  end
end
