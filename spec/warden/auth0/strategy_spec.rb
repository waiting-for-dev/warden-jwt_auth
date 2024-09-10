# frozen_string_literal: true

require 'spec_helper'

describe Warden::Auth0::Strategy do
  include_context 'configuration'
  include_context 'fixtures'

  let(:valid_token) { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJqdGkiOiJiYWYxZGMzOC0wMzMxLTQwZDMtYjgwYS02MGZkMmM1YTIxYzMiLCJpc3MiOiJodHRwczovL3Rlc3QtZGV2LmV1LmF1dGgwLmNvbS8ifQ.bohJzH8dseepETezDOs3uX6oJcwJvhQwMyWnmO8OY4E' }

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

    context 'when Authorization header exists' do
      it 'returns true when the token issuer matches the configured one' do
        env = { 'HTTP_AUTHORIZATION' => "Bearer #{valid_token}" }
        strategy = described_class.new(env)

        expect(strategy).to be_valid
      end

      it 'returns false when the token issuer does not match the configured one' do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJqdGkiOiJiYWYxZGMzOC0wMzMxLTQwZDMtYjgwYS02MGZkMmM1YTIxYzMiLCJpc3MiOiJodHRwczovL3dyb25nLWRldi5ldS5hdXRoMC5jb20vIn0.puYkNmvLkqqKSrWAB8zYKSbmHydBTPFxhkxK1AZec_k' }
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
      let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{valid_token}" } }
      let(:strategy) { described_class.new(env, :user) }

      before { strategy.authenticate! }

      it 'succeeds authentication' do
        expect(strategy).to be_successful
      end

      it 'logs in user returned by current mapping' do
        expect(strategy.user).to eq(user)
      end
    end
  end
end
