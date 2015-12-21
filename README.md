# Stripe Cache

A little HTTP caching layer over Stripe's API.

See more: https://paper.dropbox.com/doc/Stripe-Caching-Proxy-hT4QlXjEZzQWsPRLAK02b

### Running

0. `export DATABASE_URL=<db_url>` (See http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html for url formatting)
0. `rake db:migrate`


### Tests

`./spec/` has some unit and integration level tests.  The integration tests are
unusual in that they actually run the application server in a thread and then
test requests against that Using the Stripe gem to ensure API compatability.

Tests do not clear the DB between runs.  Temporary DBs should be used  and
deleted after each test run.
