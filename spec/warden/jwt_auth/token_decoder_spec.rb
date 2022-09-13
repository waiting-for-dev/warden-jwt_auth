# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::TokenDecoder do
  include_context 'configuration'

  describe '#call(token)' do
    let(:payload) { { 'sub' => '1', 'jti' => '123' } }
    let(:token) { ::JWT.encode(payload, secret, 'HS256') }
    let(:rotated_token) { ::JWT.encode(payload, secret_rotation, 'HS256') }

    it 'returns the payload encoded in the token' do
      expect(described_class.new.call(token)).to eq(payload)
    end

    it 'returns the payload encoded in the token when its rotated' do
      expect(described_class.new.call(rotated_token)).to eq(payload)
    end

  end
end
