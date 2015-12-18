require 'rack/request'
require 'stripe_cache/proxy'
require 'stripe_cache/cache'
require 'stripe_cache/http_client'

module StripeCache
  # A rack application which processes all requests via +Proxy+
  class Api
    attr_reader :cache, :http
    def initialize
      @cache = DbCache.new
      @http = HttpClient.new
    end

    def call(env)
      request = Rack::Request.new(env)
      handler = Proxy.new(request, cache: cache, http: http)
      [handler.status, handler.headers, [handler.body]]
    end
  end
end
