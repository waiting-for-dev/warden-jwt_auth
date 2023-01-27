# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::TokenDecoder do
  include_context 'configuration'

  describe '#call(token)' do
    let(:payload) { { 'sub' => '1', 'jti' => '123' } }
    let(:token) { ::JWT.encode(payload, secret, 'HS256') }
    let(:rotated_token) { ::JWT.encode(payload, rotation_secret, 'HS256') }
    let(:invalid_token) { ::JWT.encode(payload, 'invalid', 'HS256') }

    it 'returns the payload encoded in the token' do
      expect(described_class.new.call(token)).to eq(payload)
    end

    it 'raises an error if decode fails' do
      expect { described_class.new.call(invalid_token) }.to raise_error(JWT::VerificationError)
    end

    it 'raises an error if no secret is set' do
      expect { described_class.new.call(nil) }.to raise_error(JWT::DecodeError)
    end

    it 'returns the payload encoded in the token when it\'s rotated' do
      expect(described_class.new.call(rotated_token)).to eq(payload)
    end
  end
end
