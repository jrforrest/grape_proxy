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
        cache.get(request) || request_upstream_get
      else
        request_upstream_post
      end
    end

    def request_upstream_get
      http.get(
        'https://api.stripe.com/' + request.path,
        Authorization: request.headers['Authorization'],
        params: request.params)
    end

    def request_upstream_post
      http.send(
        method,
        'https://api.stripe.com/' + request.path,
        request.params,
        {Authorization: request.headers['Authorization']})
    end

    def method
      request.request_method.downcase.to_sym
    end
  end
end
