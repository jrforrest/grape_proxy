require 'stripe_cache/request_headers'

using StripeCache::RequestHeaders

module StripeCache
  class Cache
    def initialize
      @entries = Hash.new
    end

    def get(request)
      @entries[key(request)]
    end

    private

    def key(request)
      [request.path, request.headers, request.params]
    end
  end
end
