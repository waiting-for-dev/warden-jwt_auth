# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::UserEncoder do
  include_context 'configuration'
  include_context 'fixtures'

  let(:token_payload) { described_class.new.call(user, :user, 'aud') }
  let(:token) { token_payload[0] }
  let(:payload) { token_payload[1] }

  describe '#call(user, scope)' do
    it 'merges in user `jwt_subject` result as sub claim' do
      expect(payload['sub']).to eq(user.jwt_subject)
    end

    it 'merges in given scope as `scp` claim' do
      expect(payload['scp']).to eq('user')
    end

    it 'merges in given aud as `aud` claim' do
      expect(payload['aud']).to eq('aud')
    end

    it 'merges in user `jwt_payload` result' do
      expect(payload['foo']).to eq(user.jwt_payload['foo'])
    end
  end
end
