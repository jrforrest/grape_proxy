require 'spec_helper'
require 'stripe_cache/api'
require 'stripe'
require 'rack'

describe 'Stripe proxy' do
  before(:all) do
    Thread.new do
      Rack::Handler::Webrick.run(StripeCache::Api, port: '9393')
    end

    Kernel.sleep(1)

    Stripe.connect_base = 'localhost:9393'
    Stripe.api_key = 'sk_test_BQokikJOvBiI2HlWgH4olfQ2'
  end

  it 'hits the stripe API' do
    res = Stripe::Balance.retrieve()
    expect(res.available).not_to be_nil
  end

  it 'works for post requests' do
    Stripe::Charge.create(
      amount: 400,
      currency: :usd,
        source: 'tok_17JB6O2eZvKYlo2CekrJeU2Y',
        description: 'truck stop services')
  end
end
