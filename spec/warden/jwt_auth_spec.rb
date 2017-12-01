# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth do
  it 'has a version number' do
    expect(Warden::JWTAuth::VERSION).not_to be nil
  end

  describe '#config' do
    describe '#mappings' do
      context 'when the mapping is a constant name' do
        it 'resolves to the constant' do
          described_class.configure do |config|
            config.mappings = { user: 'Fixtures::UserRepo' }
          end

          expect(described_class.config.mappings).to eq({
            user: Fixtures::UserRepo
          })
        end
      end
    end

    describe '#revocation_strategies' do
      context 'when the mapping is a constant name' do
        it 'resolves to the constant' do
          described_class.configure do |config|
            config.mappings = { user: 'Fixtures::RevocationStrategy' }
          end

          expect(described_class.config.mappings).to eq({
            user: Fixtures::RevocationStrategy
          })
        end
      end
    end
  end
end
