# Cassie Test Harnessing

We're all trying to avoid overly integrated tests. When it comes to the persistance layer adapter, that can be tough. Cassie provides a simple test harness to allow you to stub out the `cassie-driver` layer when it makes sense to do so.

### Usage

```ruby
class Cassie::Query
  def self.session
    @session ||= CassandraFake::Session.new
  end
end
```

This `CassandraFake::Session` provides a few things, while stubbing out access to the actual persistance layer.

##### Seeing the last statement executed

```ruby
some_query.execute
some_query.session
=> #<CassandraFake::Session:0x007fd03e29a688>
some_query.session.last_statement.cql
=> "SELECT * FROM users LIMIT 1;"
```

##### Mocking rows returned in result from call to `execute`

```ruby
some_query.session.rows = [{id: 1, username: "eprothro"}]
some_query.fetch
=> [#<Struct id=1, username="eprothro">]
```
