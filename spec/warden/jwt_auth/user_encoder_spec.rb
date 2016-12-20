# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::UserEncoder do
  include_context 'configuration'
  include_context 'fixtures'

  let(:token) { described_class.new.call(user, :user) }
  let(:payload) { Warden::JWTAuth::TokenDecoder.new.call(token) }

  describe '#call(user, scope)' do
    it 'merges in user `jwt_subject` result as sub claim' do
      expect(payload['sub']).to eq(user.jwt_subject)
    end

    it 'merges in given scope as `scp` claim' do
      expect(payload['scp']).to eq('user')
    end

    it 'merges in user `jwt_payload` result' do
      expect(payload['foo']).to eq(user.jwt_payload['foo'])
    end
  end
end
