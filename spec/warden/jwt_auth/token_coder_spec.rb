# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::TokenCoder do
  include_context 'configuration'

  describe '::encode(sub, config)' do
    let(:expiration_time) { config.expiration_time }
    let(:sub) { '1' }
    let(:token) { described_class.encode(sub, config) }
    let(:decoded_payload) do
      ::JWT.decode(token, secret, true, algorithn: 'HS256')[0]
    end

    it 'encodes given payload using HS256 algorithm and secret as key' do
      expect { decoded_payload }.not_to raise_error
    end

    it 'adds a sub claim with provided sub argument' do
      expect(decoded_payload['sub']).to eq('1')
    end

    it 'adds an `iat` claim with the issue time' do
      iat = decoded_payload['iat']

      expect(Time.at(iat).to_date).to eq(Date.today)
    end

    it 'adds an `exp` claim with configured expiration time' do
      exp = decoded_payload['exp']

      expect(Time.at(exp)).to be_within(10).of(Time.now + expiration_time)
    end

    it 'adds a `jti` claim with a random unique id' do
      expect(decoded_payload['jti']).not_to be_nil
    end
  end

  describe '::decode(token)' do
    include_context 'blacklist'

    let(:payload) { { 'sub' => '1', 'jti' => '123' } }
    let(:token) { ::JWT.encode(payload, secret, 'HS256') }

    it 'decodes using HS256 algorithm and secret as key' do
      expect(described_class.decode(token, config)).to eq(payload)
    end

    it 'raises a JWT::DecodeError if `jwt` is in the blacklist' do
      blacklist.push('123')

      expect do
        described_class.decode(token, config)
      end.to raise_error(JWT::DecodeError)
    end

    it 'does not raise a JWT::DecodeError if `jwt` is not the blacklist' do
      expect(described_class.decode(token, config)).to eq(payload)
    end
  end
end
