# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth do
  it 'has a version number' do
    expect(Warden::JWTAuth::VERSION).not_to be nil
  end

  describe '#config.mappings' do
    context 'when the mapping is a constant name' do
      before do
        described_class.configure do |config|
          config.mappings = { user: 'Fixtures::UserRepo' }
        end
      end

      it 'resolves to the constant' do
        expect(described_class.config.mappings).to eq(
          user: Fixtures::UserRepo
        )
      end
    end
  end

  describe '#config.revocation_strategies' do
    context 'when the mapping is a constant name' do
      before do
        described_class.configure do |config|
          config.revocation_strategies = { user: 'Fixtures::RevocationStrategy' }
        end
      end

      it 'resolves to the constant' do
        expect(described_class.config.revocation_strategies).to eq(
          user: Fixtures::RevocationStrategy
        )
      end
    end
  end
end
