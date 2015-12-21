# Stripe Cache

A little HTTP caching layer over Stripe's API.


### Running

0. `export DATABASE_URL=<db_url>` (See
   http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html
   for url formatting)
0. `rake db:migrate`
0. `rackup config.ru`

##### Env Vars

- `DATABASE_URL` Uses the DB for the given env
- `CACHE_TYPE` set to `mem` uses the memory cache instead of DB
  (ttl is not supported in the memory cache though.)

### Tests

__NOTE: DB at `DATABASE_URL` will be cleared on each integration test run__

`./spec/` has some unit and integration level tests.  The integration tests are
unusual in that they actually run the application server in a thread and then
test requests against that Using the Stripe gem to ensure API compatability.

You can use `be rspec` by itself from the root dir to run everything, though
for the integration tests to work you're going to have to give a `DATABASE_URL`
in the env.
