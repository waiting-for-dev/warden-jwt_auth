# frozen_string_literal: true

shared_context 'feature' do
  require 'rack'

  let(:failure_app) { ->(_env) { [401, {}, ['unauthorized']] } }
  let(:auth_app) do
    lambda do |env|
      proxy = env['warden']
      proxy.authenticate!(scope: :user)
      success_response
    end
  end

  let(:success_response) { [200, {}, ['success']] }

  let(:pristine_env) { {} }

  def add_warden(builder)
    builder.use Warden::Manager do |manager|
      manager.default_strategies(:auth0)
      manager.failure_app = failure_app
    end
  end

  def call_app(app, env, request_tuple)
    method, path = request_tuple
    env = env.dup
    env['PATH_INFO'] = path
    env['REQUEST_METHOD'] = method
    app.call(env)
  end

  def generate_token(user, scope, env)
    aud = Warden::Auth0::EnvHelper.aud_header(env)
    token, _payload = Warden::Auth0::UserEncoder.new.call(user, scope, aud)
    token
  end

  def env_with_token(env, token)
    Warden::Auth0::HeaderParser.to_env(env, token)
  end
end
