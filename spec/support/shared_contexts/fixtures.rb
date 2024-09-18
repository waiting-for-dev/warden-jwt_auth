# frozen_string_literal: true

shared_context 'fixtures' do
  let(:user_repo) { Fixtures::UserRepo }
  let(:nil_user_repo) { Fixtures::NilUserRepo }
  let(:user) { Fixtures::User.instance }
  let(:valid_token) { 'eyJhbGciOiJSUzI1NiIsInR5cCI6ImF0K2p3dCIsImtpZCI6IjFiTFpieDU5LUhnTzlqNG9idTFNSyJ9.eyJpc3MiOiJodHRwczovL2F1dGguYjJiLmRldi4xa29tbWE1Z3JhZC5jb20vIiwic3ViIjoiYXV0aDB8MTI0M3xwYXJ0bmVyQGV4YW1wbGUuY29tIiwiYXVkIjpbImh0dHBzOi8vb3MuZGV2LjFrb21tYTVncmFkLmNvbS9hcGkiLCJodHRwczovL2VpbnNrNWctYjJiLWRldi5ldS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNzI2NjYwODM3LCJleHAiOjE3MjY3NDcyMzcsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwiLCJqdGkiOiIyNGVuWExVZEgxRkR3YnU2ZVdaWmRzIiwiY2xpZW50X2lkIjoiRVMwRTk0RzhPRXJVMkhTRkoxNzlTdUJNVndHblVNZXYiLCJwZXJtaXNzaW9ucyI6W119.E1RUPLiq6AxB19BABOJuw1tj5ozK-ep8kg_kQrRibTjmvbiIhULDZOg60TXwXDTYT6rpUDvnPMrx8EgvQt8E6RelOpbf3lHyqjugdy0ykH2YG8-u_42N0nNwiy86cv_PdUxGEXGnCcWPGjCOracIs3D22JLTQzu2wICJRWzJWE7WFclP54uCrgp9elS5kzF_2jGu3eXpkIVnA6VtgilN5350ZXZzhGtbGieHVkv_CQlTuSbyYw5sE5TznQO85ZxfyYdVDe0qGplSBwVV79PuL-HPGlccJ_Y-6di4V64L7nIDr7uS2Caev2dpkYatTK0KffpV99md9kiDj8rTfrrTwg' }
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
