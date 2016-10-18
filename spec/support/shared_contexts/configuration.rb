# frozen_string_literal: true

shared_context 'configuration' do
  let(:config) { Warden::JWTAuth.config }
  let(:secret) { config.secret }

  before { config.secret = '123' }
end
