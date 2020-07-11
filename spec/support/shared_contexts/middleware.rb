# frozen_string_literal: true

shared_context 'middleware' do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  let(:dummy_app) { ->(_env) { [200, {}, []] } }

  def warden_app(app)
    Warden::Manager.new(app)
  end

  after { Warden.test_reset! }
end
