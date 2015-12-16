require 'spec_helper'
require 'rack/request'
require 'stripe_cache/request_headers'

using StripeCache::RequestHeaders

module StripeCache
  describe RequestHeaders do
    let(:env) do
      { "CONTENT_TYPE"=>"application/x-www-form-urlencoded",
        "GATEWAY_INTERFACE"=>"CGI/1.1",
        "PATH_INFO"=>"/v1/balance",
        "QUERY_STRING"=>"",
        "REMOTE_ADDR"=>"::1",
        "REMOTE_HOST"=>"localhost",
        "REQUEST_METHOD"=>"GET",
        "REQUEST_URI"=>"http://localhost:3301/v1/balance",
        "SCRIPT_NAME"=>"",
        "SERVER_NAME"=>"localhost",
        "SERVER_PORT"=>"3301",
        "SERVER_PROTOCOL"=>"HTTP/1.1",
        "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/2.2.1/2015-02-26)",
        "HTTP_ACCEPT"=>"*/*; q=0.5, application/xml",
        "HTTP_ACCEPT_ENCODING"=>"gzip, deflate",
        "HTTP_USER_AGENT"=>"Stripe/v1 RubyBindings/1.31.0",
        "HTTP_AUTHORIZATION"=>"Bearer sk_test_BQokikJOvBiI2HlWgH4olfQ2",
        "HTTP_HOST"=>"localhost:3301",
        "rack.version"=>[1, 3]}
    end

    let(:request) { Rack::Request.new(env) }

    it 'Renames the headers back to their original format' do
      expect(request.headers['Accept']).to eql('*/*; q=0.5, application/xml')
    end

    it 'only grabs the headers' do
        expect(request.headers.length).to eql(5)
    end
  end
end
