# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::UserDecoder do
  include_context 'configuration'
  include_context 'fixtures'

  let(:token) { Warden::JWTAuth::UserEncoder.new(config).call(user, :user) }
  let(:payload) { Warden::JWTAuth::TokenDecoder.new(config).call(token) }

  describe '#call(token, scope)' do
    it 'returns encoded user' do
      expect(
        described_class.new(config).call(token, :user)
      ).to eq(user)
    end

    it 'raises RevokedToken if the token has been revoked' do
      revocation_strategy.revoke(payload, user)

      expect do
        described_class.new(config).call(token, :user)
      end.to raise_error(Warden::JWTAuth::Errors::RevokedToken)
    end

    it 'raises WrongScope if encoded token does not match with intended one' do
      expect do
        described_class.new(config).call(token, :unknown)
      end.to raise_error(Warden::JWTAuth::Errors::WrongScope)
    end
  end
end
