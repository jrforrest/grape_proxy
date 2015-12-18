require 'spec_helper'
require 'stripe_cache/api'
require 'stripe'
require 'rack'

describe 'Stripe proxy' do
  before(:all) do
    @app = StripeCache::Api.new

    Thread.abort_on_exception = true

    Thread.new do
      Rack::Handler::WEBrick.run(@app, {Port: 9393})
    end

    Kernel.sleep(3)

    Stripe.api_base = 'localhost:9393'
    Stripe.api_key = 'sk_test_BQokikJOvBiI2HlWgH4olfQ2'
  end

  let(:cache) { @app.cache }
  let(:http) { @app.http }

  it 'hits the stripe API' do
    res = Stripe::Balance.retrieve()
    expect(res.available).not_to be_nil
  end

  it 'caches a request if its made twice' do
    first = Stripe::Balance.retrieve()
    expect(cache.num_entries).to eql(1)
    expect(http).not_to receive(:get)
    second = Stripe::Balance.retrieve()

    expect(first.to_hash).to eql(second.to_hash)
  end

  it 'works for post requests' do
    begin
      Stripe::Transfer.create(
        amount: 400,
        currency: :usd,
        destination: 'acct_1032D82eZvKYlodC',
        description: 'truck stop services')
    rescue Stripe::InvalidRequestError => e
      json = JSON.parse(e.http_body)
      expect(json['error']['type']).to eql('invalid_request_error')
    end
  end
end