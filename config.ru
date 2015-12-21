$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'stripe_cache/api'

run StripeCache::Api.new
