# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::TokenRevoker do
  include_context 'configuration'
  include_context 'fixtures'

  describe '#call(token)' do
    let(:revocation_strategy) { revocation_strategies[:user] }

    let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user) }
    let(:payload) { Warden::JWTAuth::TokenDecoder.new.call(token) }

    it 'revokes given token' do
      described_class.new.call(token)

      expect(revocation_strategy.jwt_revoked?(payload, user)).to eq(true)
    end

    it 'revokes calling revocation_strategy with decoded payload and user' do
      expect(revocation_strategy).to(receive(:revoke_jwt).with(payload, user))

      described_class.new.call(token)
    end
  end
end
