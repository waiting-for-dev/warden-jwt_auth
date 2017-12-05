# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::TokenRevoker do
  include_context 'configuration'
  include_context 'fixtures'

  describe '#call(token)' do
    let(:revocation_strategy) { revocation_strategies[:user] }

    let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, 'aud') }
    let(:payload) { Warden::JWTAuth::TokenDecoder.new.call(token) }

    it 'revokes given token' do
      described_class.new.call(token)

      expect(revocation_strategy.jwt_revoked?(payload, user)).to eq(true)
    end

    it 'revokes calling revocation_strategy with decoded payload and user' do
      expect(revocation_strategy).to(receive(:revoke_jwt).with(payload, user))

      described_class.new.call(token)
    end

    context 'when token is expired' do
      before { Warden::JWTAuth.config.expiration_time = -1 }

      it 'silently ignores it' do
        expect { described_class.new.call(token) }.not_to raise_error
      end

      after { Warden::JWTAuth.config.expiration_time = 3600 }
    end
  end
end
