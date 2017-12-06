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

  # :reek:FeatureEnvy
  def build_app(app)
    builder = Rack::Builder.new
    builder.use Warden::JWTAuth::Middleware
    add_warden(builder)
    builder.run(app)
    builder
  end

  # :reek:FeatureEnvy
  def add_warden(builder)
    builder.use Warden::Manager do |manager|
      manager.default_strategies(:jwt)
      manager.failure_app = failure_app
    end
  end

  # :reek:UtilityFunction
  def call_app(app, env, request_tuple)
    method, path = request_tuple
    env = env.dup
    env['PATH_INFO'] = path
    env['REQUEST_METHOD'] = method
    app.call(env)
  end

  # :reek:UtilityFunction
  def generate_token(user, scope, env)
    token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, scope, env[aud_header])
    token
  end

  # :reek:UtilityFunction
  def env_with_token(env, token)
    Warden::JWTAuth::HeaderParser.to_env(env, token)
  end
end
