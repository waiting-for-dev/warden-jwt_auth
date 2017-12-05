# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Hooks do
  include_context 'configuration'
  include_context 'middleware'
  include_context 'fixtures'

  context 'with user set' do
    let(:app) { warden_app(dummy_app) }

    # :reek:UtilityFunction
    def token(request)
      request.env['warden-jwt_auth.token']
    end

    context 'when method and path match and scope is known ' do
      before do
        login_as user, scope: :user

        post '/sign_in'
      end

      it 'codes a token and adds it to env' do
        expect(token(last_request)).not_to be_nil
      end

      it 'adds user info to the token' do
        payload = Warden::JWTAuth::TokenDecoder.new.call(token(last_request))

        expect(payload['sub']).to eq(user.jwt_subject)
      end
    end

    context 'when scope is unknown' do
      it 'does nothing' do
        login_as user, scope: :unknown

        post '/sign_in'

        expect(token(last_request)).to be_nil
      end
    end

    context 'when path does not match' do
      it 'does nothing' do
        login_as user, scope: :user

        post '/'

        expect(token(last_request)).to be_nil
      end
    end

    context 'when method does not match' do
      it 'does nothing' do
        login_as user, scope: :user

        get '/sign_in'

        expect(token(last_request)).to be_nil
      end
    end
  end
end
