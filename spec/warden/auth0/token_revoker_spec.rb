# frozen_string_literal: true

require 'spec_helper'

describe Warden::Auth0::TokenRevoker do
  include_context 'configuration'
  include_context 'fixtures'

  describe '#call(token)' do
    let(:revocation_strategy) { revocation_strategies[:user] }

    let(:token_payload) { Warden::Auth0::UserEncoder.new.call(user, :user, 'aud') }
    let(:token) { token_payload[0] }
    let(:payload) { token_payload[1] }

    it 'revokes given token' do
      described_class.new.call(token)

      expect(revocation_strategy.jwt_revoked?(payload, user)).to eq(true)
    end

    it 'revokes calling revocation_strategy with decoded payload and user' do
      allow(revocation_strategy).to(receive(:revoke_jwt).with(payload, user))

      described_class.new.call(token)

      expect(revocation_strategy).to(have_received(:revoke_jwt).with(payload, user))
    end

    context 'when token is expired' do
      before { Warden::Auth0.config.expiration_time = -1 }

      after { Warden::Auth0.config.expiration_time = 3600 }

      it 'silently ignores it' do
        expect { described_class.new.call(token) }.not_to raise_error
      end
    end
  end
end
