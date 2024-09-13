# frozen_string_literal: true

shared_context 'token_decoder' do
  let(:token_decoder) { instance_double(Warden::Auth0::TokenDecoder) }
  let(:token_payload) { nil }

  before do
    allow(Warden::Auth0::TokenDecoder)
      .to receive(:new)
      .and_return(token_decoder)

    allow(token_decoder)
      .to receive(:call)
      .and_return(token_payload)
  end
end
