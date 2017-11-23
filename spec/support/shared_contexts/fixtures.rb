# frozen_string_literal: true

shared_context 'fixtures' do
  let(:user_repo) { Fixtures::UserRepo }
  let(:nil_user_repo) { Fixtures::NilUserRepo }
  let(:user) { Fixtures::User.instance }
end
