require 'rack/request'

module StripeCache
  # A rack application which processes all requests via +Proxy+
  class Api
    def initialize
      @cache = Cache.new
      @http = HttpClient.new
    end

    def call(env)
      request = Rack::Request.new(env)
      handler = Proxy.new(request, cache: cache, http: http)
      [handler.status, handler.headers, handler.body]
    end

    private
    attr_reader :cache, :http
  end
end
