# Cassie

Cassie provides support for the components most applications need to work with a Cassandra persistence layer:

* Database configuration and efficient session management
* Versioned schema migrations
* Query classes
* Test harnessing

Each component is designed to be abstract. A given application may only use `Cassie::Connection` and nothing else.
Cassie attempts to support use cases such as that in a lightweight and straightforward manner.

### Installation

```ruby
# Gemfile
gem 'cassie', '~> 1.0.0.alpha'
```
or
```bash
$ gem install cassie --pre
```

### Database Configuration

Cassie provies database connection configuration (e.g. cluster and session) per environment. Support for a default YAML back-end is provided.

```bash
$ cassie config:generate
```

`Cassie::configurations` are loaded from this configuration file at runtime.

```ruby
Cassie.confurations
=> {"development"=>{"hosts"=>["127.0.0.1"], "port"=>9042, "keyspace"=>"my_app_development"}, "test"=>{"hosts"=>["127.0.0.1"], "port"=>9042, "idle_timeout"=>"nil", "keyspace"=>"my_app_test"}, "production"=>{"hosts"=>["cass1.my_app.biz", "cass2.my_app.biz", "cass3.my_app.biz"], "port"=>9042, "keyspace"=>"my_app_production"}}
```

Setting `Cassie::env` results in the corresponding `Cassie::configuration` being used.

```ruby
Cassie.env = "production"

Cassie.configuration
{"hosts"=>["cass1.my_app.biz", "cass2.my_app.biz", "cass3.my_app.biz"], "port"=>9042, "keyspace"=>"my_app_production"}

Cassie.keyspace
=> 'my_app_production'
```

See the [`Configuration` README](./lib/cassie/configuration/README.md#readme) for more on features and usage.

See [`cassie-rails`](https://github.com/eprothro/cassie-rails) for Rails integration with Cassie if you're using Rails.


### Connection Handling

Cassie provides cluster and session connection creation according to `cassie-driver` [best practices](http://www.datastax.com/dev/blog/4-simple-rules-when-using-the-datastax-drivers-for-cassandra).

##### Using cached cluster and session objects

`cluster` and `session` objects are created, cached, and reused globally.

```ruby
# continuing from above 'production' configuration

Cassie.cluster
=> #<Cassandra::Cluster:0x3fc087f7f9b8> #<= configured with production options

Cassie.session
=> #<Cassandra::Session:0x3fc084caa344> #<= session scoped to 'my_app_production' keyspace

Cassie.session(nil)
=> #<Cassandra::Session:0x3fc084caa344> #<= session without scoped keyspace

Cassie.session('my_other_keyspace')
=> #<Cassandra::Session:0x3fc084caa344> #<= session scoped to 'my_other_keyspace' keyspace
```

If using Cassie Configuration as described above via `cassandra.yml`, cluster configuration will happen automatically. If not, assign a cluster options hash to `Cassie::configuration` before using a `cluster` or `session`.

##### Using cluster and session objects in Classes

Include `Cassie::Connection` in a class for `session` and `keyspace` functionality in your objects.

```ruby
class MyQuery
  include Cassie::Connection

  # An explicit keyspace that will determine the session used
  # instead of falling back to the value in Cassie::keyspace
  keyspace :some_other_keyspace

  def find_user(id)
    # session is a vanilla Cassandra::Session
    # connected to `some_other_keyspace`
    session.execute('SELECT * FROM users WHERE id = ?;', arguments: [id])
  end
end
```

See the [Connection README](./lib/cassie/connection_handler/README.md#readme) for more on features and usage.

### Cassandra Control

Cassie provides simple commands to control Cassandra execution in *nix development. These simplify execution and reduce output to provide faster management of your Cassandra processes.

#### Start
```
$ cassie start
Starting Cassandra...
[✓] Cassandra Running
```

#### Stop
```
$ cassie stop
Stopping Cassandra...
[✓] Cassandra Stopped
```

```
$ cassie stop
Couldn't single out a Cassandra process.
  - Is cqlsh running?
  - Kill all cassandra processes with --all
    - 9542  | /usr/local/apache-cassandra-3.0.8/bin/cqlsh.py
    - 2832  | org.apache.cassandra.service.CassandraDaemon

$ cassie stop --all
Stopping Cassandra...
[✓] Cassandra Stopped
```

#### Restart / Kick
```
$ cassie restart
Stopping Cassandra...
[✓] Cassandra Stopped
Starting Cassandra...
[✓] Cassandra Running
```

#### Tail / Log
```
$ cassie tail
Tailing Cassandra system log, Ctrl-C to stop...
  /usr/local/cassandra/logs/system.log:

INFO  [main] 2016-09-23 11:18:05,073 StorageService.java:1902 - Node localhost/127.0.0.1 state jump to NORMAL
INFO  [main] 2016-09-23 11:18:05,215 NativeTransportService.java:75 - Netty using Java NIO event loop
INFO  [main] 2016-09-23 11:18:05,343 Server.java:159 - Using Netty Version: [netty-buffer=netty-buffer-4.0.23.Final.208198c, netty-codec=netty-codec-4.0.23.Final.208198c, netty-codec-http=netty-codec-http-4.0.23.Final.208198c, netty-codec-socks=netty-codec-socks-4.0.23.Final.208198c, netty-common=netty-common-4.0.23.Final.208198c, netty-handler=netty-handler-4.0.23.Final.208198c, netty-transport=netty-transport-4.0.23.Final.208198c, netty-transport-rxtx=netty-transport-rxtx-4.0.23.Final.208198c, netty-transport-sctp=netty-transport-sctp-4.0.23.Final.208198c, netty-transport-udt=netty-transport-udt-4.0.23.Final.208198c]
INFO  [main] 2016-09-23 11:18:05,344 Server.java:160 - Starting listening for CQL clients on localhost/127.0.0.1:9042 (unencrypted)...
INFO  [main] 2016-09-23 11:18:05,407 CassandraDaemon.java:477 - Not starting RPC server as requested. Use JMX (StorageService->startRPCServer()) or nodetool (enablethrift) to start it
```

### Versioned Migrations

Cassie allows you to migrate between schema states using semantically versioned, incremental mutations.

Schema Version information is stored in Cassandra persistence, in the `cassie_schema` keyspace, by default.


#### Tasks

| Task | Description |
| --- | --- |
| migration:create | Generates an empty migration file prefixed with the next semantic version number |
| migrate | Migrates the schema by running the `up` methods in any migrations starting after the current schema version |
| rollback | Rolls back the schema by running the `down` methods starting with the current schema version |
| migration:initialize | Create an initial migration based on the current Cassandra non-system schema |
| migration:import | Import existing `cassandra_migrations` migration files and convert to semantic versioning |
| schema:version | Print the current schema version information for the Cassandra cluster |
| schema:history | Print the the historical version information the current Cassandra cluster state |
| structure:dump | Dumps the schema for all non-system keyspaces in CQL format (`db/structure.cql` by default) |
| structure:load | Creates the schema by executing the CQL schema in the structure file (`db/structure.cql` by default) |

See the [Migrations README](./lib/cassie/migration/README.md#readme) for more on features and usage.

### Query Classes

Cassie provides base Query Classes to manage interactions to the database.
Create application specific subclasses and construct queries with a simple CQL DSL.

```ruby
class UserByUsernameQuery < Cassie::Query

  select_from :users_by_username

  where :username, :eq

  consistency :quorum
end
```

```ruby
UserByUsernameQuery.new.fetch_first(username: "eprothro")
=> #<Struct user_id=123, username="eprothro">
```

See the [Queries README](./lib/cassie/statements/README.md#readme) for more on features and usage.

### Test Harnessing

Avoid making queries into the persistnace layer when you can afford it.

```ruby
some_query = SomeQuery.new
some_query.extend(Cassie::Testing::Fake::Query)
some_query.session
=> #<Cassie::Testing::Fake::Session::Session:0x007fd03e29a688>

some_query.execute

some_query.session.last_statement
=> #<Cassandra::Statements::Simple:0x3ffde09930b8 @cql="SELECT * FROM users LIMIT 1;" @params=[]>
```

See the [Testing README](./lib/cassie/testing/README.md#readme) for more on features and usage.

### Contributing

Pull requests and issues are welcome. Please include updates to the CHANGELOG as needed.

#### Unit tests

Unit tests should provide complete coverage of features and should not depend on an available Cassandra server.

Run the unit suite with `rake spec` or `rspec` after running `bundle`.

#### `Integration/db` tests

Integration tests that rely on a Cassandra server exist as an extra 'sanity check' layer. Please don't use them as an excuse to not write solid unit tests. Please add them if they seem like a good idea!

Run the full suite with Cassandra-based specs using `rake full_spec` or `rspec --options .rspec-with-db`.

#### Releasing (maintainers only)

Run `rake release` to test (Cassandra running locally requried), build, and publish gem. Followed by an automatic version bump (patch).

Bump version minor / major with `gem bump --version <minor|major>`.

Test, build, and install into local gems with `rake install`.