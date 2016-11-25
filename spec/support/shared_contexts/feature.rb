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

  def build_app(app)
    builder = Rack::Builder.new
    builder.use Warden::JWTAuth::Middleware, config
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
  def call_app(app, env, path)
    env = env.dup
    env['PATH_INFO'] = path
    app.call(env)
  end

  # :reek:UtilityFunction
  def generate_token(user, scope)
    Warden::JWTAuth::UserCoder.encode(user, scope)
  end

  # :reek:UtilityFunction
  def env_with_token(env, token)
    Warden::JWTAuth::HeaderParser.to_env(env, token)
  end
end
