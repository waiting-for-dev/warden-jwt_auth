# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::UserCoder do
  include_context 'configuration'
  include_context 'fixtures'

  let(:token) { described_class.encode(user, :user, config) }
  let(:payload) { Warden::JWTAuth::TokenCoder.decode(token, config) }

  describe '::encode(user, scope, config)' do
    it 'merges in user `jwt_subject` result as sub claim' do
      expect(payload['sub']).to eq(user.jwt_subject)
    end

    it 'merges in given scope as `scp` claim' do
      expect(payload['scp']).to eq('user')
    end

    it 'merges in user `jwt_payload` result' do
      expect(payload['foo']).to eq(user.jwt_payload['foo'])
    end
  end

  describe '::decode(token, scope, config)' do
    it 'returns encoded user' do
      expect(
        described_class.decode(token, :user, config)
      ).to eq(user)
    end

    it 'raises RevokedToken if the token has been revoked' do
      revocation_strategy.revoke(payload, user)

      expect do
        described_class.decode(token, :user, config)
      end.to raise_error(Warden::JWTAuth::Errors::RevokedToken)
    end

    it 'raises WrongScope if encoded token does not match with intended one' do
      expect do
        described_class.decode(token, :unknown, config)
      end.to raise_error(Warden::JWTAuth::Errors::WrongScope)
    end
  end

  describe '::decode_from_payload(payload, config)' do
    it 'returns encoded user' do
      expect(
        described_class.decode_from_payload(payload, config)
      ).to eq(user)
    end
  end
end
