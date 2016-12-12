# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::TokenDecoder do
  include_context 'configuration'

  describe '#call(token)' do
    let(:payload) { { 'sub' => '1', 'jti' => '123' } }
    let(:token) { ::JWT.encode(payload, secret, 'HS256') }

    it 'returns the payload encoded in the token' do
      expect(described_class.new(config).call(token)).to eq(payload)
    end
  end
end
