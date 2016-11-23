# frozen_string_literal: true

shared_context 'fixtures' do
  let(:user_repo) { Fixtures::UserRepo }
  let(:user) { Fixtures::User.instance }
end
