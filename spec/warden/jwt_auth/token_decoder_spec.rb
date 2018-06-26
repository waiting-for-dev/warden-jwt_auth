# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::TokenDecoder do
  include_context 'configuration'

  describe '#call(token)' do
    let(:payload) { { 'sub' => '1', 'jti' => '123', 'scp' => 'user' } }
    let(:token) { ::JWT.encode(payload, secret, 'HS256') }

    it 'returns the payload encoded in the token' do
      expect(described_class.new.call(token)).to eq(payload)
    end

    context 'when jti is not supplied' do
    let(:payload) { { 'sub' => '1', 'scp' => 'user' } }

      it 'returns the payload encoded in the token' do
        expect(described_class.new.call(token)).to eq(payload)
      end
    end

    context 'when scp is not supplied' do
    let(:payload) { { 'sub' => '1', 'jti' => '123' } }
    let(:payload_with_default) { { 'sub' => '1', 'jti' => '123', 'scp' => 'user' } }

      it 'returns the payload with user as default scope' do
        expect(described_class.new.call(token)).to eq(payload_with_default)
      end
    end
  end
end
