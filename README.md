# Stripe Cache

A little HTTP caching layer over Stripe's API.

See more: https://paper.dropbox.com/doc/Stripe-Caching-Proxy-hT4QlXjEZzQWsPRLAK02b

### Tests

`./spec/` has some unit and integration level tests.  The integration tests are
unusual in that they actually run the application server in a thread and then
test requests against that Using the Stripe gem to ensure API compatability.
