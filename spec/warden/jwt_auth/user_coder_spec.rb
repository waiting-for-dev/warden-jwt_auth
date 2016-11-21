# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::UserCoder do
  include_context 'configuration'

  describe '::encode(user, config)' do
    let(:user) { Fixtures::User.new }
    let(:token) { described_class.encode(user, :user, config) }
    let(:decoded_payload) do
      Warden::JWTAuth::TokenCoder.decode(token, config)
    end

    it 'merges in user `jwt_subject` result as sub claim' do
      expect(decoded_payload['sub']).to eq(user.jwt_subject)
    end

    it 'merges in given `scope` result as scp claim' do
      expect(decoded_payload['scp']).to eq('user')
    end

    it 'merges in user `jwt_payload` result' do
      expect(decoded_payload['foo']).to eq(user.jwt_payload['foo'])
    end
  end

  describe '::decode(token, scope, config)' do
    let(:user) { Fixtures::User.new }
    let(:token) { described_class.encode(user, config) }
    let(:payload) { Warden::JWTAuth::TokenCoder.decode(token, config) }

    it 'returns encoded user' do
      expect(
        described_class.decode(token, :user, config)
      ).to be_an_instance_of(Fixtures::User)
    end

    it 'raises a JWT::DecodeError if the token has been revoked' do
      revocation_strategy.revoke(payload)

      expect do
        described_class.decode(token, :user, config)
      end.to raise_error(JWT::DecodeError)
    end

    it 'does not raise a JWT::DecodeError if the token has not been revoked' do
      expect(
        described_class.decode(token, :user, config)
      ).to be_an_instance_of(Fixtures::User)
    end
  end
end
