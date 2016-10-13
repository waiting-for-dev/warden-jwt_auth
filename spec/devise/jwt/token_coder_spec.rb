# frozen_string_literal: true

require 'spec_helper'

describe Devise::Jwt::TokenCoder do
  before do
    Devise::Jwt.configure { |config| config.secret = '123' }
  end

  let(:config) { Devise::Jwt.config }
  let(:secret) { config.secret }

  describe '::encode(payload)' do
    let(:expiration_time) { config.expiration_time }
    let(:payload) { { 'foo' => 'bar' } }
    let(:token) { described_class.encode(payload, config) }
    let(:decoded_payload) do
      ::JWT.decode(token, secret, true, algorithn: 'HS256')[0]
    end

    it 'encodes given payload using HS256 algorithm and secret as key' do
      expect { decoded_payload }.not_to raise_error
    end

    it 'merges given payload in the automatic claims' do
      expect(decoded_payload['foo']).to eq('bar')
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
    # :reek:UtilityFunction
    def use_blacklist(items = [])
      Devise::Jwt.configure { |config| config.blacklist = items }
    end

    let(:payload) { { 'foo' => 'bar', 'jti' => '123' } }
    let(:token) { ::JWT.encode(payload, secret, 'HS256') }

    it 'decodes using HS256 algorithm and secret as key' do
      expect(described_class.decode(token, config)).to eq(payload)
    end

    it 'raises a JWT::DecodeError if `jwt` is in the blacklist' do
      use_blacklist(['123'])

      expect do
        described_class.decode(token, config)
      end.to raise_error(JWT::DecodeError)
    end

    it 'does not raise a JWT::DecodeError if `jwt` is not the blacklist' do
      use_blacklist(['345'])

      expect(described_class.decode(token, config)).to eq(payload)
    end
  end
end
