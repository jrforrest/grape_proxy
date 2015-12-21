require 'rspec'
require 'pry'

$LOAD_PATH << File.expand_path('../lib/', __FILE__)

RSpec.configure do |config|
  # Start a server before integration tests
  config.before(:all, type: :integration) do
    @app = StripeCache::Api.new

    Thread.abort_on_exception = true

    Thread.new do
      Rack::Handler::WEBrick.run(@app, {Port: 9393})
    end

    Kernel.sleep(3)

    Stripe.api_base = 'localhost:9393'
    Stripe.api_key = 'sk_test_BQokikJOvBiI2HlWgH4olfQ2'
  end

  config.before(:each, type: :integration) { @app.cache.clear }
end
