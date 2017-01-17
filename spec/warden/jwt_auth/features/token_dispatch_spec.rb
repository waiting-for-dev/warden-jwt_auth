# frozen_string_literal: true

require 'spec_helper'

describe 'Token dispatch', type: :feature do
  include_context 'configuration'
  include_context 'fixtures'
  include_context 'feature'

  let(:signed_in_app) do
    dispatch_app = lambda do |env|
      proxy = env['warden']
      proxy.set_user(user, scope: :user)
      success_response
    end
    build_app(dispatch_app)
  end

  let(:not_signed_in_app) do
    dispatch_app = lambda do |env|
      success_response
    end
    build_app(dispatch_app)
  end

  context 'when path and method match with configured' do
    it 'adds the token to Authorization response header' do
      headers = call_app(signed_in_app, pristine_env, ['POST', '/sign_in'])[1]

      expect(headers).to have_key('Authorization')
    end
  end

  context 'when path does not match with configured' do
    it 'does not add the token to the response' do
      headers = call_app(signed_in_app, pristine_env, ['POST', '/'])[1]

      expect(headers).not_to have_key('Authorization')
    end
  end

  context 'when method does not match with configured' do
    it 'does not add the token to the response' do
      headers = call_app(signed_in_app, pristine_env, ['GET', '/sign_in'])[1]

      expect(headers).not_to have_key('Authorization')
    end
  end

  context 'when user is not set' do
    it 'does not raise an error' do
      status = call_app(not_signed_in_app, pristine_env, ['GET', '/'])[0]

      expect(status).to eq(200)
    end
  end
end
