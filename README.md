## Cassie
[![Code Health](https://codeclimate.com/github/eprothro/cassie/badges/gpa.svg)](https://codeclimate.com/github/eprothro/cassie)
[![Test Coverage](https://codeclimate.com/github/eprothro/cassie/badges/coverage.svg)](https://codeclimate.com/github/eprothro/cassie/coverage)
[![Build Status](https://travis-ci.org/eprothro/cassie.svg?branch=latest_stable)](https://travis-ci.org/eprothro/cassie/branches)
[![Inline Docs](http://inch-ci.org/github/eprothro/cassie.svg?branch=latest_stable)](http://www.rubydoc.info/github/eprothro/cassie/dev)


Cassie provides ruby application support for Apache Cassandra. It provides components that most applications will need that are out of scope of the official `cassandra-driver`, including:

* Database configuration
* Cluster/session management
* Cassandra server command helpers
* Versioned schema migrations
* Query classes and DSL
* Test harnessing

Each of these components are designed to be used independently or together in a ruby application. If you want to manage your own configuration, use Cassie for session management, and some other gem for your queries -- great!

**Tested against:**

* Ruby: MRI 2.2, 2.3, and JRuby 1.9
* `cassandra-driver` 3.0

### Installation

[![Gem Version](https://badge.fury.io/rb/cassie.svg)](https://badge.fury.io/rb/cassie)

```ruby
# Gemfile
gem 'cassie', '~> 1.0.4'
```

or

```bash
$ gem install cassie
```

See [`cassie-rails`](https://github.com/eprothro/cassie-rails) for Rails integration.

### Database Configuration

Cassie provies database connection configuration (e.g. cluster and session) per environment. Support for a default YAML back-end is provided.

```bash
$ cassie configuration:generate
```

`Cassie::configurations` are loaded from this configuration file at runtime.

```ruby
Cassie.confurations
=> {"development"=>{"hosts"=>["127.0.0.1"], "port"=>9042, "keyspace"=>"my_app_development"}, "test"=>{"hosts"=>["127.0.0.1"], "port"=>9042, "idle_timeout"=>"nil", "keyspace"=>"my_app_test"}, "production"=>{"hosts"=>["cass1.my_app.biz", "cass2.my_app.biz", "cass3.my_app.biz"], "port"=>9042, "keyspace"=>"my_app_production"}}
```

Cassie.configuration` pulls the appropriate configuration from `Cassie.configurations`, based on `Cassie.env`.

```ruby
Cassie.env = "production"

Cassie.configuration
{"hosts"=>["cass1.my_app.biz", "cass2.my_app.biz", "cass3.my_app.biz"], "port"=>9042, "keyspace"=>"my_app_production"}

Cassie.keyspace
=> 'my_app_production'
```

`Cassie.env` prefers `ENV["CASSANDRA_ENV"]`, then `ENV["RACK_ENV"]`, and falls back to `development`.

See the [`Configuration` README](./lib/cassie/configuration/README.md#readme) for more on features and usage.


### Connection Handling

Cassie provides cluster and session connection creation according to `cassie-driver` [best practices](http://www.datastax.com/dev/blog/4-simple-rules-when-using-the-datastax-drivers-for-cassandra).

##### Using cached cluster and session objects

`cluster` and `session` objects are created, cached, and reused globally.

```ruby
# continuing from above 'production' configuration

Cassie.cluster
=> #<Cassandra::Cluster:0x3fc032f7f9b8> #<= configured with production cluster `configuration` options

Cassie.session
=> #<Cassandra::Session:0x3fc084caa344> #<= session scoped to default 'my_app_production' keyspace

Cassie.session(nil)
=> #<Cassandra::Session:0x3fc084caba22> #<= session without scoped keyspace

Cassie.session('my_other_keyspace')
=> #<Cassandra::Session:0x3fc084cabf33> #<= session scoped to 'my_other_keyspace' keyspace

Cassie.session
=> #<Cassandra::Session:0x3fc084caa344> #<= cached session, scoped to default 'my_app_production' keyspace
```

If using Cassie Configuration as described above via `cassandra.yml`, cluster configuration happens automatically. If not, assign a cluster environments hash to `Cassie::configurations` before using a `cluster` or `session`.

##### Using cluster and session objects in Classes

Include `Cassie::Connection` in a class for `session` and `keyspace` functionality in your objects.

```ruby
class MyQuery
  include Cassie::Connection

  # An explicit keyspace that will determine the session used
  # instead of falling back to the value in `Cassie.keyspace`
  # for all instances of this class.
  # Override `#keyspace` for per-object evaluation.
  keyspace :some_other_keyspace

  def find_user(id)
    # `session` is a vanilla Cassandra::Session
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

#### Restart

```
$ cassie restart
Stopping Cassandra...
[✓] Cassandra Stopped
Starting Cassandra...
[✓] Cassandra Running
```

#### Tail

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

### Versioned Schema Migrations

Cassie allows you to migrate between schema states using semantically versioned, incremental migration files.

Schema Version information is stored in Cassandra persistence, in the `cassie_schema.versions` table (configurable).

An executable schema file keeps the current state of the schema in-repo, at `db/cassandra/schema.cql`, (configurable).

Various `cassie <task>` tasks are used to manage the schema version and migrations.

#### Tasks

| Task | Description |
| --- | --- |
| migrations:import | Import existing `cassandra_migrations` migration files and convert to semantic versioning |
| migration:create | Generates an empty migration file prefixed with the next semantic version number |
| migrate | Migrates the schema by running the `up` methods in any migrations starting after the current schema version |
| migrate:reset | runs schema:reset and migrate |
| schema:init | Create versioned migrations schema, and the environment's keyspace if it doesn't exist |
| schema:version | Print the current schema version information for the Cassandra cluster |
| schema:history | Print the the historical version information the current Cassandra cluster state |
| schema:status | Print the the migration status for each local migration (up/down) |
| schema:load | Creates the schema by executing the CQL schema in the schema file (`db/cassandra/schema.cql` by default) |
| schema:drop | drop keyspace(s) |
| schema:dump | Dumps the schema for all non-system keyspaces in CQL format (`db/cassandra/schema.cql` by default) |
| schema:reset | runs schema:drop and schema:load|
| schema:import | Create an initial migration based on the current Cassandra non-system schema |

See the [Migrations README](./lib/cassie/schema/README.md#readme) for more on features and usage.

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
some_query.session.rows = [{'user_id' => 123, 'username' => 'eprothro'}]

some_query.fetch
=> [#<Struct user_id=123, username="eprothro">]

some_query.session.last_statement
=> #<Cassandra::Statements::Simple:0x3ffde09930b8 @cql="SELECT * FROM users LIMIT 500;" @params=[]>
```

See the [Testing README](./lib/cassie/testing/README.md#readme) for more on features and usage.

### Contributing

Pull requests and issues are welcome. Please read the [contributing guidelines](./CONTRIBUTING.md).