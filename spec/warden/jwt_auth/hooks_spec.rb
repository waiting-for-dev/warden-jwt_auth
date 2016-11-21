# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Warden::JWTAuth::Hooks do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  include_context 'configuration'

  let(:user) { Fixtures::User.new }
  let(:dummy_app) { ->(_env) { [200, {}, []] } }
  let(:app) { Warden::Manager.new(dummy_app) }

  context 'After set user' do
    context 'when path matches and user is set for a known mapping' do
      it "adds a token to env['warden-jwt_auth.token']" do
        login_as user, scope: :user

        get '/sign_in'

        expect(last_request.env['warden-jwt_auth.token']).not_to be_nil
      end
    end

    context 'when path matches and user is set for a unknown mapping' do
      it 'adds nothing to env' do
        login_as user, scope: :unknown

        get '/sign_in'

        expect(last_request.env['warden-jwt_auth.token']).to be_nil
      end
    end

    context 'when path does not match even if user is for a known mapping' do
      it 'adds nothing to env' do
        login_as user, scope: :user

        get '/'

        expect(last_request.env['warden-jwt_auth.token']).to be_nil
      end
    end
  end

  after { Warden.test_reset! }
end
