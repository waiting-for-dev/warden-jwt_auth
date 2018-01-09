# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::EnvHelper do
  include_context 'configuration'

  describe '::path_info(env)' do
    it 'returns PATH_INFO' do
      env = { 'PATH_INFO' => '/foo' }

      expect(described_class.path_info(env)).to eq('/foo')
    end

    it 'returns empty strig when PATH_INFO is nil' do
      env = {}

      expect(described_class.path_info(env)).to eq('')
    end
  end

  describe '::request_method(env)' do
    it 'returns REQUEST_METHOD' do
      env = { 'REQUEST_METHOD' => 'POST' }

      expect(described_class.request_method(env)) == 'POST'
    end
  end

  describe '::authorization_header(env)' do
    it 'returns HTTP_AUTHORIZATION' do
      env = { 'HTTP_AUTHORIZATION' => 'Bearer 123' }

      expect(described_class.authorization_header(env)) == 'Bearer 123'
    end
  end

  describe '::set_authorization_header(env, value)' do
    it 'sets value as HTTP_AUTHORIZATION' do
      env = {}

      updated_env = described_class.set_authorization_header(env, 'Bearer 123')

      expect(updated_env['HTTP_AUTHORIZATION']).to eq('Bearer 123')
    end
  end

  describe '::aud_header(env)' do
    it 'returns configured aud_header' do
      env = { env_aud_header => 'FOO_AUD' }

      expect(described_class.aud_header(env)).to eq('FOO_AUD')
    end
  end

  describe '::no_api_request?(env)' do
    it 'returns true when `Accept` header contains `text/html`' do
      env = { 'HTTP_ACCEPT' => 'text/html' }

      expect(described_class.no_api_request?(env)).to eq(true)
    end

    it 'returns true when `Accept` header contains `text/javascript`' do
      env = { 'HTTP_ACCEPT' => 'text/javascript' }

      expect(described_class.no_api_request?(env)).to eq(true)
    end

    it 'returns false when `Accept` header contains something else' do
      env = { 'HTTP_ACCEPT' => 'application/json' }

      expect(described_class.no_api_request?(env)).to eq(false)
    end

    it 'returns false when `Accept` header is not present' do
      env = {}

      expect(described_class.no_api_request?(env)).to eq(false)
    end
  end
end
