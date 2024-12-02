# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Hooks do
  include_context 'configuration'
  include_context 'middleware'
  include_context 'fixtures'

  context 'with user set' do
    let(:app) { warden_app(dummy_app) }

    def token(request)
      request.env['warden-jwt_auth.token']
    end

    def payload(request)
      token = token(request)
      Warden::JWTAuth::TokenDecoder.new.call(token)
    end

    context 'when method and path match and scope is known ' do
      before do
        header aud_header.gsub('HTTP_', ''), 'warden_tests'
        login_as user, scope: :user
      end

      it 'codes a token and adds it to env' do
        post '/sign_in'

        expect(token(last_request)).not_to be_nil
      end

      it 'adds user info to the token' do
        post '/sign_in'

        expect(payload(last_request)['sub']).to eq(user.jwt_subject)
      end

      it 'adds configured client id header into the aud claim' do
        post '/sign_in'

        expect(payload(last_request)['aud']).to eq('warden_tests')
      end

      it 'calls before_jwt_dispatch method in the user' do
        allow(user).to receive(:before_jwt_dispatch)

        post '/sign_in'

        expect(user).to have_received(:before_jwt_dispatch)
      end

      it 'calls on_jwt_dispatch method in the user' do
        allow(user).to receive(:on_jwt_dispatch)

        post '/sign_in'

        expect(user).to have_received(:on_jwt_dispatch)
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
