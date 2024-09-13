# frozen_string_literal: true

shared_context 'fixtures' do
  let(:user_repo) { Fixtures::UserRepo }
  let(:nil_user_repo) { Fixtures::NilUserRepo }
  let(:user) { Fixtures::User.instance }
  let(:valid_token) { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJqdGkiOiJiYWYxZGMzOC0wMzMxLTQwZDMtYjgwYS02MGZkMmM1YTIxYzMiLCJpc3MiOiJodHRwczovL3Rlc3QtZGV2LmV1LmF1dGgwLmNvbS8ifQ.bohJzH8dseepETezDOs3uX6oJcwJvhQwMyWnmO8OY4E' }
  let(:wrong_issuer_token) { 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJqdGkiOiJiYWYxZGMzOC0wMzMxLTQwZDMtYjgwYS02MGZkMmM1YTIxYzMiLCJpc3MiOiJodHRwczovL3Rlc3QtZGV2LmV1LmF1dGgwLmNvbS8ifQ.iMV9ZwCkU1S6Gx8v56uA6oGiM6KLdHnaV_epUDImgHg' }
  let(:invalid_token) { "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJqdGkiOiJiYWYxZGMzOC0wMzMxLTQwZDMtYjgwYS02MGZkMmM1YTIxYzMiLCJpc3MiOiJodHRwczovL3Rlc3QtZGV2LmV1LmF1dGgwLmNvbS8ifQ.iMV9ZwCkU1S6Gx8v56uA6oGiM6KLdHnaV_epUDImgHg" }
  let(:valid_payload) do
    {
      "sub" => "1234567890",
      "name" => "John Doe",
      "iat" => 1516239022,
      "jti" => "baf1dc38-0331-40d3-b80a-60fd2c5a21c3",
      "iss" => "https://test-dev.eu.auth0.com/",
      "aud" => "https://test.com/api"
    }
  end

  let(:wrong_iss_payload) do
    {
      "sub" => "1234567890",
      "name" => "John Doe",
      "iat" => 1516239022,
      "jti" => "baf1dc38-0331-40d3-b80a-60fd2c5a21c3",
      "iss" => "https://wrong.eu.auth0.com/",
      "aud" => "https://test.com/api"
    }
  end
  let(:wrong_aud_payload) {
    {
      "sub" => "1234567890",
      "name" => "John Doe",
      "iat" => 1516239022,
      "jti" => "baf1dc38-0331-40d3-b80a-60fd2c5a21c3",
      "iss" => "https://test-dev.eu.auth0.com/",
      "aud" => "https://test.com/api/wrong"
    }
  }
end
