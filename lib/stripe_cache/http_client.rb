require 'rest-client'
module StripeCache
  # Bitty wrapper 'round RestClient that returns failed requests instead of
  # raising errors
  class HttpClient
    [:get, :put, :post, :delete].each do |m|
      define_method(m) do |*args|
        begin
          wrap_successful_response(RestClient.send(m, *args))
        rescue RestClient::RequestFailed => e
          e.response
        end
      end
    end

    def wrap_successful_response(body)
      Struct.new(:body, :status, :headers).new(body, 200, {})
    end
  end
end
