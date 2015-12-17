require 'rest-client'
module StripeCache
  # Bitty wrapper 'round RestClient that returns failed requests instead of
  # raising errors
  class HttpClient
    [:get, :put, :post, :delete].each do |m|
      define_method(m, *args) do
        begin
          RestClient.send(m, *args)
        rescue RestClient::RequestFailed => e
          e.response
        end
      end
    end
  end
end
