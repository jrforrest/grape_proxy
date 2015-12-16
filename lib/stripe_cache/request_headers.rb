module StripeCache
  module RequestHeaders
    refine Rack::Request do

      # Provides all the HTTP headers in the request with capitalization,
      # name and format preserved
      def headers
        @headers ||= env.select {|k,v| k.start_with? 'HTTP_'}
          .map {|k,v| [k.sub(/^HTTP_/, ''), v]}
          .map {|k,v| [k.split('_').collect(&:capitalize).join('-'), v]}
          .to_h
      end
    end
  end
end
