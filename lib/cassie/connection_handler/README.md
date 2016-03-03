# Cassie Connection Handling

Cassie provides cluster and session connection handling that adheres to `cassandra-driver` best practices:
  * Maintains 1 `Cassandra::Cluster` instance
  * Maintains 1 `Cassandra::Session` per keyspace (or less)

Cassie also provides a `Connection` module to allow easy integration of connection handling into application classes.


#### Core functionality

`Cassie` extends `ConnectionHandler`, providing functionality to act as a connection handler using its `configuration` and `keyspace` attributes.

```ruby
Cassie.cluster
=> #<Cassandra::Cluster:0x3fec245dceb0> # <= cluster instance configured according to `Cassie::configuration`

Cassie.keyspace
=> "default_keyspace"

Cassie.session
=> #<Cassandra::Session:0x3fec24b13668>

Cassie.session(nil)
=> #<Cassandra::Session:0x3fec24b339b8>

Cassie.session('my_other_keyspace')
=> #<Cassandra::Session:0x3fec24b558a8>

Cassie.sessions
=> {
    "default_keyspace"=>#<Cassandra::Session:0x3fec24b13668>,
    ""=>#<Cassandra::Session:0x3fec24b13668>,
    "my_other_keyspace" >#<Cassandra::Session:0x3fec24b558a8>
   }

# Future session retrieval reuses previously connected sessions
Cassie.session
=> #<Cassandra::Session:0x3fec24b13668>

Cassie.sessions
=> {
    "default_keyspace"=>#<Cassandra::Session:0x3fec24b13668>,
    ""=>#<Cassandra::Session:0x3fec24b13668>,
    "my_other_keyspace" >#<Cassandra::Session:0x3fec24b558a8>
   }
```


#### Mixin functionality

Including `Connection` gives convenience accessors that allow overriding and fallback behavior.

```ruby
class HelpfulCounter
  include Cassie::Connection

  def user_count
    session.execute('SELECT count(*) FROM users WHERE id = ?;').rows.first['count']
  end
end
```

Ignoring the likely irresponsible example query used -- The object falls back to using the `Cassie::keyspace` value by default.

```ruby
Cassie.keyspace
=> "default_keyspace"

object = HelpfulCounter.new

object.keyspace
=> "default_keyspace"

object.user_count
=> 302525
```

The keyspace can be set at the class level.

```ruby
class Analytics::HelpfulCounter
  include Cassie::Connection

  keyspace :analytics_keyspace

  def user_count
    session.execute('SELECT count(*) FROM users WHERE id = ?;').rows.first['count']
  end
end

Cassie.keyspace
=> "default_keyspace"

object = Analytics::HelpfulCounter.new

object.keyspace
=> "analytics_keyspace"

object.user_count
=> 300715

```

Or at the object level

```
Cassie.keyspace
=> "default_keyspace"

object = HelpfulCounter.new

object.keyspace
=> "default_keyspace"

object.user_count
=> 302525

object.keyspace = "analytics_keyspace"
=> "analytics_keyspace"

object.user_count
=> 300715
