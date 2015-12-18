require 'stripe_cache/request_headers'
require 'digest'
require 'sequel'

using StripeCache::RequestHeaders

module StripeCache
  class DbCache
    def initialize
    end

    Request = Struct.new(:status, :body, :headers)

    def get(request)
      upstream_request = table.filter(
        path: request.path,
        params_hash: params_hash(request),
        auth: request.headers['Authorization']
      ).first

      if upstream_request
        Request.new(200, upstream_request[:response_body], {})
      end
    end

    # todo: This introduces a race condition between get->set
    def set(request, response)
      table.insert(
        path: request.path,
        auth: request.headers['Authorization'],
        params_hash: params_hash(request),
        response_body: response.body)
      response
    end

    def num_entries
      table.count
    end

    private
    def connection
      @connection ||= Sequel.connect(ENV.fetch('DATABASE_URL'))
    end

    def params_hash(request)
      Digest::SHA1.hexdigest(request.params.to_s)
    end

    def table
      connection[:cached_requests]
    end
  end

  class MemoryCache
    def initialize
      @entries = Hash.new
    end

    def get(request)
      @entries[key(request)]
    end

    def set(request, response)
      @entries[key(request)] = response
    end

    def num_entries
      @entries.keys.length
    end

    def key(request)
      [request.path, request.headers, request.params]
    end
  end
end
