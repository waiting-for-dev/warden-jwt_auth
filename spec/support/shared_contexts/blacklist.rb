# frozen_string_literal: true

shared_context 'blacklist' do
  let(:blacklist) { config.blacklist }

  before do
    config.blacklist = []
    config.blacklist_token_paths = '^/sign_out$'
  end
end
