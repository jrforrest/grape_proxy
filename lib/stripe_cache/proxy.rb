require 'rack/request'
require 'stripe_cache/request_headers'

using StripeCache::RequestHeaders

module StripeCache
  class Proxy
    extend Forwardable

    attr_reader :request

    def initialize(request, http:, cache:)
      @request = request
      @http = http
      @cache = cache
    end

    delegate [:status, :headers, :body] => :stripe_response

    private
    attr_reader :http, :cache

    def stripe_response
      @stripe_response ||= if(method == :get)
        cache.get(request) || request_upstream
      else
        request_upstream
      end
    end

    def request_upstream
      http.send(
        method,
        'https://api.stripe.com/' + request.path,
        Authorization: request.headers['Authorization'],
        params: request.params)
    end

    def method
      request.request_method.downcase.to_sym
    end
  end
end
