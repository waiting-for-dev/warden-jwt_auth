# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::HeaderParser do
  describe '#from_env(env)' do
    context 'when authorization method is Bearer' do
      it 'returns token' do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer 123' }

        expect(described_class.from_env(env)).to eq('123')
      end
    end

    context 'when authorization method is something else' do
      it 'returns nil' do
        env = { 'HTTP_AUTHORIZATION' => 'Basic 123' }

        expect(described_class.from_env(env)).to be_nil
      end
    end

    context 'when there is no authorization method' do
      it 'returns nil' do
        env = { 'HTTP_AUTHORIZATION' => '123' }

        expect(described_class.from_env(env)).to be_nil
      end
    end

    context 'when there is no Authorization header' do
      it 'returns nil' do
        env = {}

        expect(described_class.from_env(env)).to be_nil
      end
    end
  end

  describe '#to_env(env, token)' do
    it 'returns a copy of env with token added in Authorization header' do
      env = {}

      env = described_class.to_env(env, '123')

      expect(env).to eq('HTTP_AUTHORIZATION' => 'Bearer 123')
    end
  end

  describe '#to_headers(headers, token)' do
    it 'returns a copy of headers with token added to Authorization key' do
      headers = {}

      headers = described_class.to_headers(headers, '123')

      expect(headers).to eq('Authorization' => 'Bearer 123')
    end


    describe 'custom token header' do
      it 'returns configured token_header' do
        allow(Warden::JWTAuth.config).to receive(:token_header).and_return('Test_Authorization')

        headers = {}

        headers = described_class.to_headers(headers, '123')

        expect(headers).to eq('Test_Authorization' => 'Bearer 123')
      end
    end
  end
end
