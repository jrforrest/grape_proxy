require 'grape'

module StripeCache
  class Api < Grape::API
    get '/' do
      'hello world'
    end
  end
end
