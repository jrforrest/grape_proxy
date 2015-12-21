require 'stripe_cache/request_headers'
require 'digest'
require 'sequel'

using StripeCache::RequestHeaders

module StripeCache
  class DbCache
    Request = Struct.new(:status, :body, :headers)

    def get(request)
      clear_expired(request)
      upstream_request = entries_for(request)
        .where {|t| t.created_at > Time.now - ttl }
        .first

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
        created_at: Time.now,
        response_body: response.body)
      response
    end

    def num_entries
      table.count
    end

    def clear
      table.delete
    end

    private

    # Clears expired entries for the given request
    def clear_expired(request)
      entries_for(request)
        .where {|t| t.created_at < Time.now - ttl }
        .delete
    end

    def entries_for(request)
      table.filter(
        path: request.path,
        params_hash: params_hash(request),
        auth: request.headers['Authorization']
      )
    end

    def ttl
      ENV['TTL_SECS'] || 60 * 10
    end

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
      warn 'StripeCache::MemoryCache does not support TTL!'
      @entries = Hash.new
    end

    def get(request)
      @entries[key(request)]
    end

    def set(request, response)
      @entries[key(request)] = response
    end

    def clear
      @entries = Hash.new
    end

    def num_entries
      @entries.keys.length
    end

    def key(request)
      [request.path, request.headers, request.params]
    end
  end
end
