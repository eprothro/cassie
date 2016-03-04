# Cassie

Cassie provides support for the components most applications need to work with a Cassandra persistence layer:

* Database configuration and efficient session management
* Versioned schema migrations
* Query classes
* Test harnessing

Each component attempts to adhere to a "take it or leave it" mindset. A given application may only use `Cassie::Connection` and nothing else.
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

`Cassie::configurations` are loaded from the generated file during runtime.

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

##### Using global cluster and session objects

`cluster` and `session` objects are created, cached in `sessions` and reused globally.

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

If using Cassie Configuration as described above via `cassandra.yml`, cluster configuration will happen automatically. If not, assign a cluster options hash to `Cassie.configuration` before using a `cluster` or `session`.

##### Using cluster and session objects in Classes

Including `Cassie::Connection` in a class provides `session` (among others) class and instance convenience methods.

```ruby
class MyQuery
  include Cassie::Connection

  def find_user(id)
    # session is a vanilla Cassandra::Session
    session.execute('SELECT * FROM my_keyspace.users WHERE id = ?;', arguments: [id])
  end
end
```

See the [Connection README](./lib/cassie/connection_handler/README.md#readme) for more on features and usage.


### Versioned Migrations

Essence of features/usage.

Link to more info in the `migrations` README.


### Query Classes

Cassie provides a base Query Class to manage interactions to the database.
Create your own subclasses and construct queries with a simple CQL DSL.

```ruby
class UserByUsernameQuery < Cassie::Query

  select :users_by_username

  where :username, :eq
end
```

```ruby
UserByUsernameQuery.new.find(username: "eprothro")
=> #<Struct user_id=123, username="eprothro">
```

See the [Query README](./lib/cassie/queries/README.md#readme) for more on features and usage.

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