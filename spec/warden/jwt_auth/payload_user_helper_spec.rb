# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::PayloadUserHelper do
  include_context 'configuration'
  include_context 'fixtures'

  describe '::find_user(payload, config)' do
    it 'returns user encoded in a payload for given scope' do
      payload = { 'sub' => 1, 'scp' => 'user' }

      expect(described_class.find_user(payload, config)).to eq(user)
    end
  end

  describe '::scope_matches?(payload, scope)' do
    context 'when given scope matches the one encoded in payload' do
      it 'returns true' do
        payload = { 'scp' => 'user' }

        expect(described_class.scope_matches?(payload, :user)).to eq(true)
      end
    end

    context 'when given scope does not match the one encoded in payload' do
      it 'returns false' do
        payload = { 'scp' => 'unknown' }

        expect(described_class.scope_matches?(payload, :user)).to eq(false)
      end
    end
  end

  describe '::payload_for_user(user, scope)' do
    let(:payload) { described_class.payload_for_user(user, :user) }

    it 'adds a `sub` claim with the result on `#jwt_subject` on user' do
      expect(payload['sub']).to eq(user.jwt_subject)
    end

    it 'adds a `scp` claim with given scope' do
      expect(payload['scp']).to eq('user')
    end

    it 'merges claims defined in user `#jwt_payload`' do
      expect(payload['foo']).to eq('bar')
    end
  end
end
