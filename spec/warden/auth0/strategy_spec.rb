# frozen_string_literal: true

require 'spec_helper'

describe Warden::Auth0::Strategy do
  include_context 'fixtures'
  include_context 'configuration'
  include_context 'token_decoder'

  it 'adds Auth0::Strategy to Warden with auth0 name' do
    expect(Warden::Strategies._strategies).to include(
      auth0: described_class
    )
  end

  describe '#valid?' do
    context 'when Authorization header does not exist' do
      it 'returns false' do
        env = {}
        strategy = described_class.new(env)

        expect(strategy).not_to be_valid
      end
    end

    context 'when token issuer and aud match the configured ones' do
      let(:token_payload) { valid_payload }

      it 'returns true' do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer some-token' }

        strategy = described_class.new(env)

        expect(strategy).to be_valid
      end
    end

    context 'when token issuer does not match the configured one' do
      let(:token_payload) { wrong_iss_payload }

      it 'returns false when the token issuer does not match the configured one' do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer some-token' }
        strategy = described_class.new(env)

        expect(strategy).not_to be_valid
      end
    end

    context 'when token aud does not match the configured one' do
      let(:token_payload) { wrong_aud_payload }

      it 'returns false when the token aud does not match the configured one' do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer some-token' }
        strategy = described_class.new(env)

        expect(strategy).not_to be_valid
      end
    end
  end

  describe '#persist?' do
    it 'returns false' do
      expect(described_class.new({}).store?).to eq(false)
    end
  end

  describe '#authenticate!' do
    context 'when token is invalid' do
      let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer 123' } }
      let(:strategy) { described_class.new(env) }

      before do
        allow(token_decoder)
          .to receive(:call)
          .and_raise(JWT::VerificationError)
        strategy.authenticate!
      end

      it 'fails authentication' do
        expect(strategy).not_to be_successful
      end

      it 'halts authentication' do
        expect(strategy).to be_halted
      end
    end

    context 'when token is valid' do
      let(:token_payload) { valid_payload }
      let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer some-token' } }
      let(:strategy) { described_class.new(env) }

      before { strategy.authenticate! }

      it 'succeeds authentication' do
        expect(strategy).to be_successful
      end

      it 'logs in user returned by current mapping' do
        expect(strategy.user).to eq(user)
      end
    end

    context 'when no user is found' do
      let(:token_payload) { valid_payload }
      let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer some-token' } }
      let(:strategy) { described_class.new(env) }
      let(:user) { nil }

      before do
        Warden::Strategies.add(:auth0, Warden::Auth0::Strategy) do
          def user_resolver(decoded_token)
           user
          end
        end
        strategy.authenticate!
      end

      it 'fails authentication' do
        expect(strategy).not_to be_successful
      end

      it 'halts authentication' do
        expect(strategy).to be_halted
      end
    end

    context 'when issuer does not match' do
      let(:token_payload) { wrong_iss_payload }
      let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer some-token' } }
      let(:strategy) { described_class.new(env) }

      before { strategy.authenticate! }

      it 'fails authentication' do
        expect(strategy).not_to be_successful
      end

      it 'halts authentication' do
        expect(strategy).to be_halted
      end
    end

    context 'when aud does not match' do
      let(:token_payload) { wrong_aud_payload }
      let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer some-token' } }
      let(:strategy) { described_class.new(env) }

      before { strategy.authenticate! }

      it 'fails authentication' do
        expect(strategy).not_to be_successful
      end

      it 'halts authentication' do
        expect(strategy).to be_halted
      end
    end
  end
end
