# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::Strategy do
  include_context 'configuration'
  include_context 'fixtures'

  it 'adds JWTAuth::Strategy to Warden with jwt name' do
    expect(Warden::Strategies._strategies).to include(
      jwt: described_class
    )
  end

  describe '#valid?' do
    context 'when Authorization header is valid' do
      it 'returns true' do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer 123' }
        strategy = described_class.new(env, :user)

        expect(strategy).to be_valid
      end
    end

    context 'when Authorization header is not valid' do
      it 'returns false' do
        env = {}
        strategy = described_class.new(env, :user)

        expect(strategy).not_to be_valid
      end
    end

    context 'when issuer claim is configured and it matches the configured issuer' do
      it 'returns true' do
        token = Warden::JWTAuth::TokenEncoder.new.call({ 'iss' => Warden::JWTAuth.config.issuer })
        env = { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }

        strategy = described_class.new(env, :user)

        expect(strategy).to be_valid
      end
    end

    context "when issuer claim is configured and it doesn't match the configured issuer" do
      it 'returns false' do
        token = Warden::JWTAuth::TokenEncoder.new.call({ 'iss' => Warden::JWTAuth.config.issuer + 'aaa' })
        env = { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }

        strategy = described_class.new(env, :user)

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
      let(:strategy) { described_class.new(env, :user) }

      before { strategy.authenticate! }

      it 'fails authentication' do
        expect(strategy).not_to be_successful
      end

      it 'halts authentication' do
        expect(strategy).to be_halted
      end
    end

    context 'when token is valid' do
      let(:token) { Warden::JWTAuth::UserEncoder.new.call(user, :user, 'aud')[0] }
      let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{token}", env_aud_header => 'aud' } }
      let(:strategy) { described_class.new(env, :user) }

      before { strategy.authenticate! }

      it 'successes authentication' do
        expect(strategy).to be_successful
      end

      it 'logs in user returned by current mapping' do
        expect(strategy.user).to eq(user)
      end
    end
  end
end
