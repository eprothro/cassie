# Cassie Test Harnessing

We're all trying to avoid overly integrated tests. When it comes to the persistance layer adapter, that can be tough. Cassie provides a simple test harness to allow you to stub out the `cassie-driver` layer when it makes sense to do so.

### Usage

```ruby
some_query.extend(Cassie::Testing::Fake::Query)
some_query.session
=> #<Cassie::Testing::Fake::Session::Session:0x007fd03e29a688>
```

This `Fake::Session` stubs out calls to the `cassandra-driver` (and thus actual persistance layer) in a way that still allows calls to `execute` to occur. It also provides a few other features.

##### Accessing the last statement executed

```ruby
some_query.execute
some_query.session.last_statement
=> #<Cassandra::Statements::Simple:0x3ffde09930b8 @cql="SELECT * FROM users LIMIT 1;" @params=[]>
some_query.session.last_statement.cql
=> "SELECT * FROM users LIMIT 1;"
```

##### Mocking rows returned in r
esult from call to `execute`

```ruby
some_query.session.rows = [{id: 1, username: "eprothro"}]
some_query.fetch
=> [#<Struct id=1, username="eprothro">]
```
