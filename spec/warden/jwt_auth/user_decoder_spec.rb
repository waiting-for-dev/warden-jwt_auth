# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::UserDecoder do
  include_context 'configuration'
  include_context 'fixtures'

  let(:token_payload) { Warden::JWTAuth::UserEncoder.new.call(user, :user, 'aud') }
  let(:token) { token_payload[0] }
  let(:payload) { token_payload[1] }

  describe '#call(token, scope, aud)' do
    it 'returns encoded user' do
      expect(
        described_class.new.call(token, :user, 'aud')
      ).to eq(user)
    end

    it 'raises RevokedToken if the token has been revoked' do
      revocation_strategies[:user].revoke_jwt(payload, user)

      expect do
        described_class.new.call(token, :user, 'aud')
      end.to raise_error(Warden::JWTAuth::Errors::RevokedToken)
    end

    it 'raises WrongScope if encoded token does not match with intended one' do
      expect do
        described_class.new.call(token, :unknown, 'aud')
      end.to raise_error(Warden::JWTAuth::Errors::WrongScope)
    end

    context 'when scope is not specified' do
      let(:token_payload) { Warden::JWTAuth::UserEncoder.new.call(user, nil, 'aud') }

      it 'returns encoded user' do
        expect(
          described_class.new.call(token, :user, 'aud')
        ).to eq(user)
      end
    end

    it 'raises NilUser if decoded user is equal to nil' do
      Warden::JWTAuth.config.mappings = { user: nil_user_repo }

      expect do
        described_class.new.call(token, :user, 'aud')
      end.to raise_error(Warden::JWTAuth::Errors::NilUser)

      Warden::JWTAuth.config.mappings = { user: user_repo }
    end

    it 'raises WrongAud if aud claim does not match with intended one' do
      expect do
        described_class.new.call(token, :user, 'another_aud')
      end.to raise_error(Warden::JWTAuth::Errors::WrongAud)
    end
  end
end
