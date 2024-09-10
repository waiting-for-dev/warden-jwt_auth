# frozen_string_literal: true

require 'spec_helper'

describe Warden::Auth0::Strategy do
  include_context 'configuration'
  include_context 'fixtures'

  it 'adds Auth0::Strategy to Warden with jwt name' do
    expect(Warden::Strategies._strategies).to include(
      auth0: described_class
    )
  end

  describe '#valid?' do
    context "when Authorization header does not exist" do
      it "returns false" do
        env = {}
        strategy = described_class.new(env)

        expect(strategy).not_to be_valid
      end
    end

    context "when Authorization header exists" do
      it "returns true when the token issuer matches the configured one" do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJpc3MiOiJodHRwczovL3Rlc3QuZXUuYXV0aDAuY29tLyJ9.7CPxvH8lkJKcrzq_2MnVp6CbY2osMhiDocpjHcIaAsE' }
        strategy = described_class.new(env)

        expect(strategy).to be_valid
      end

      it "returns false when the token issuer does not match the configured one" do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJpc3MiOiJodHRwczovL3dyb25nLmV1LmF1dGgwLmNvbS8ifQ.nXFSvsX54_LQHiHWYRa1CkstfxiY84ZShMBQom4N4JQ' }
        strategy = described_class.new(env)

        expect(strategy).not_to be_valid
      end
    end
  end

  # describe '#persist?' do
  #   it 'returns false' do
  #     expect(described_class.new({}).store?).to eq(false)
  #   end
  # end

  # describe '#authenticate!' do
  #   context 'when token is invalid' do
  #     let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer 123' } }
  #     let(:strategy) { described_class.new(env, :user) }

  #     before { strategy.authenticate! }

  #     it 'fails authentication' do
  #       expect(strategy).not_to be_successful
  #     end

  #     it 'halts authentication' do
  #       expect(strategy).to be_halted
  #     end
  #   end

  #   context 'when token is valid' do
  #     let(:token) { Warden::Auth0::UserEncoder.new.call(user, :user, 'aud')[0] }
  #     let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{token}", env_aud_header => 'aud' } }
  #     let(:strategy) { described_class.new(env, :user) }

  #     before { strategy.authenticate! }

  #     it 'successes authentication' do
  #       expect(strategy).to be_successful
  #     end

  #     it 'logs in user returned by current mapping' do
  #       expect(strategy.user).to eq(user)
  #     end
  #   end
  # end
end
