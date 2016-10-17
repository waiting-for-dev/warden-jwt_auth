# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::HeaderParser do
  describe '#parse_from_env(env)' do
    context 'when Authorization is Bearer' do
      it 'returns token' do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer 123' }

        expect(described_class.parse_from_env(env)).to eq('123')
      end
    end

    context 'when Authorization is something else' do
      it 'returns nil' do
        env = { 'HTTP_AUTHORIZATION' => 'Basic 123' }

        expect(described_class.parse_from_env(env)).to be_nil
      end
    end

    context 'when Authorization is a single word' do
      it 'returns nil' do
        env = { 'HTTP_AUTHORIZATION' => '123' }

        expect(described_class.parse_from_env(env)).to be_nil
      end
    end

    context 'when there is no Authorization' do
      it 'returns nil' do
        env = {}

        expect(described_class.parse_from_env(env)).to be_nil
      end
    end
  end

  describe '#parse_to_headers(headers, token)' do
    it 'sets token in Authorization header with Bearer method' do
      headers = {}

      described_class.parse_to_headers(headers, '123')

      expect(headers).to eq('Authorization' => 'Bearer 123')
    end
  end
end
