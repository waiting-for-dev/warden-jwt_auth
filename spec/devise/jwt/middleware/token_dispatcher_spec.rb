# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'

describe Devise::Jwt::Middleware::TokenDispatcher do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  before do
    Devise::Jwt.configure do |config|
      config.secret = '123'
      config.response_token_paths = '/sign_in'
    end
  end

  let(:config) { Devise::Jwt.config }
  let(:pristine_app) { ->(_env) { [200, {}, []] } }
  let(:warden_app) { Warden::Manager.new(pristine_app) }
  let(:app) { described_class.new(warden_app, config) }
  let(:user) do
    Class.new do
      def id
        1
      end
    end
  end

  describe '#call(env)' do
    context 'when PATH_INFO matches configured response_token_paths' do
      it 'adds token to the response if user is signed in' do
        login_as user.new
        get '/sign_in'

        expect(last_response.headers['Authorization']).not_to be_nil
      end

      it 'adds nothing to the response if user is not signed in' do
        get '/sign_in'

        expect(last_response.headers['Authorization']).to be_nil
      end
    end

    context 'when PATH_INFO does not match configured response_token_paths' do
      it 'adds nothing to the response' do
        login_as user.new
        get '/another_path'

        expect(last_response.headers['Authorization']).to be_nil
      end
    end
  end

  after { Warden.test_reset! }
end
