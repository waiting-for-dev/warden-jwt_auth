# frozen_string_literal: true

require 'spec_helper'

describe 'Token revocation', type: :feature do
  include_context 'configuration'
  include_context 'fixtures'
  include_context 'feature'

  let(:app) { build_app(auth_app) }

  context 'when path and method match with configured' do
    it 'revokes the token' do
      token = generate_token(user, :user)
      env = env_with_token(pristine_env, token)

      call_app(app, env, ['DELETE', '/sign_out'])
      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(401)
    end
  end

  context 'when path does not match with configured' do
    it 'does not revoke the token' do
      token = generate_token(user, :user)
      env = env_with_token(pristine_env, token)

      call_app(app, env, ['GET', '/'])
      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(200)
    end
  end

  context 'when method does not match with configured' do
    it 'does not revoke the token' do
      token = generate_token(user, :user)
      env = env_with_token(pristine_env, token)

      call_app(app, env, ['POST', '/sign_out'])
      status = call_app(app, env, ['GET', '/'])[0]

      expect(status).to eq(200)
    end
  end

  context 'when Authorization header is not set' do
    it 'does not raise an error' do
      status = call_app(app, pristine_env, ['GET', '/'])[0]

      expect(status).to eq(401)
    end
  end
end
