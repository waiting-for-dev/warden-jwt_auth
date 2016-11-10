# frozen_string_literal: true

shared_context 'revocation' do
  let(:revocation_strategy) { config.revocation_strategy }

  before do
    config.revocation_strategy = Fixtures::RevocationStrategy.new
    config.token_revocation_paths = '^/sign_out$'
  end
end
