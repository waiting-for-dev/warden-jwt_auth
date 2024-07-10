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

      expect(described_class.request_method(env)).to eq('POST')
    end
  end

  describe '::authorization_header(env)' do
    it 'returns configured authorization_header' do
      env = { env_token_header => 'Bearer 123' }

      expect(described_class.authorization_header(env)).to eq('Bearer 123')
    end
  end

  describe '::set_authorization_header(env, value)' do
    it 'sets value as configured token_header' do
      env = {}

      updated_env = described_class.set_authorization_header(env, 'Bearer 123')

      expect(updated_env[env_token_header]).to eq('Bearer 123')
    end
  end

  describe '::aud_header(env)' do
    it 'returns configured aud_header' do
      env = { env_aud_header => 'FOO_AUD' }

      expect(described_class.aud_header(env)).to eq('FOO_AUD')
    end
  end

  describe '::env_name(header)' do
    it 'returns env name for header' do
      header = 'Test-Authorization'

      expect(described_class.env_name(header)).to eq('HTTP_TEST_AUTHORIZATION')
    end
  end
end
