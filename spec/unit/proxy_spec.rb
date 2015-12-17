require 'spec_helper'

require 'stripe_cache/proxy'

module StripeCache
  MockResponse = Struct.new(:status, :headers, :body)
  describe Proxy do
    let(:request) do
      double.tap do |dbl|
        allow(dbl).to receive(:headers).and_return({'Authorization' => 'yada'})
        allow(dbl).to receive(:params).and_return({})
        allow(dbl).to receive(:path).and_return('/something')
        allow(dbl).to receive(:request_method).and_return('GET')
      end
    end

    let(:cache) do
      double.tap { |dbl| allow(dbl).to receive(:get) }
    end

    let(:response) do
      MockResponse.new(200, {}, 'hi!')
    end

    let(:http) do
      double.tap do |dbl|
        allow(dbl).to receive(:get).and_return(response)
      end
    end

    let(:proxy) { Proxy.new(request, http: http, cache: cache) }

    it 'makes the status headers and body of the req available' do
      expect(proxy.status).to eql(200)
    end

    context 'if the request is already in the cache' do
      let(:response) { MockResponse.new(200, {}, 'woah' ) }

      let(:cache) do
        double.tap do |dbl|
          allow(dbl).to receive(:get).and_return(response)
        end
      end

      it 'Uses the cached request' do
        expect(proxy.body).to eql('woah')
      end
    end

    context 'if the request is not in the cache' do
      it 'requests upstream' do
        expect(proxy.body).to eql('hi!')
      end
    end
  end
end
