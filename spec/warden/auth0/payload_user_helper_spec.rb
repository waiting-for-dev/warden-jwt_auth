# frozen_string_literal: true

require 'spec_helper'

describe Warden::Auth0::PayloadUserHelper do
  include_context 'configuration'
  include_context 'fixtures'

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

  describe '::aud_matches?(payload, aud)' do
    context 'when given aud matches the one encoded in payload' do
      it 'returns true' do
        payload = { 'aud' => 'foo' }

        expect(described_class.aud_matches?(payload, 'foo')).to eq(true)
      end
    end

    context 'when given aud does not match the one encoded in payload' do
      it 'returns false' do
        payload = { 'aud' => 'unknown' }

        expect(described_class.aud_matches?(payload, 'foo')).to eq(false)
      end
    end
  end

  describe '::issuer_matches?(payload, aud)' do
    context 'when given iss matches the one encoded in payload' do
      it 'returns true' do
        payload = { 'iss' => 'http://example.com' }

        expect(described_class.issuer_matches?(payload, 'http://example.com')).to eq(true)
      end
    end

    context 'when given iss does not match the one encoded in payload' do
      it 'returns false' do
        payload = { 'iss' => 'unknown' }

        expect(described_class.issuer_matches?(payload, 'http://example.com')).to eq(false)
      end
    end
  end
end
