require 'spec_helper'
require 'stripe_cache/api'
require 'stripe'
require 'rack'
require 'timecop'

describe 'Stripe proxy', type: :integration do
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

  it 'skips the cache if the old entry is older than 10 mins' do
    first = Stripe::Balance.retrieve()
    second = nil
    eleventy_one_minutes_from_now do
      expect(cache.num_entries).to eql(1)
      expect(http).to receive(:get).and_return(
        Struct.new(:status, :body, :headers).new(200, first.to_json, {})
      )
      second = Stripe::Balance.retrieve()
    end

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

  def eleventy_one_minutes_from_now
    Timecop.freeze(Time.now + 111 * 60)
    yield
    Timecop.return
  end
end
