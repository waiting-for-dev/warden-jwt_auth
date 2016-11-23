# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Hooks do
  include_context 'configuration'
  include_context 'middleware'
  include_context 'fixtures'

  context 'After set user' do
    let(:app) { warden_app(dummy_app) }

    # :reek:UtilityFunction
    def token(request)
      request.env['warden-jwt_auth.token']
    end

    context 'when path matches and user is set for a known mapping' do
      it 'codes a token and adds it to env' do
        login_as user, scope: :user

        get '/sign_in'

        expect(token(last_request)).not_to be_nil
      end
    end

    context 'when path matches and user is set for a unknown mapping' do
      it 'does nothing' do
        login_as user, scope: :unknown

        get '/sign_in'

        expect(token(last_request)).to be_nil
      end
    end

    context 'when path does not match even if user is for a known mapping' do
      it 'does nothing' do
        login_as user, scope: :user

        get '/'

        expect(token(last_request)).to be_nil
      end
    end
  end
end
