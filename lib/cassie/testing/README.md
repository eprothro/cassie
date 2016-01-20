# Cassie Test Harnessing

We're all trying to avoid overly integrated tests. When it comes to the persistance layer adapter, that can be tough. Cassie provides a simple test harness to allow you to stub out the `cassie-driver` layer when it makes sense to do so.

### Usage
Extend a `Cassie::Query` class or object with `Cassie::Testing::Fake::Query` to stub out calls to the `cassandra-driver` (and thus actual persistance layer) in a way that still allows calls to `execute` to occur.

Stubbing an object will only apply to that object, not other objects created from that class.

```ruby
some_query = SomeQuery.new
some_query.extend(Cassie::Testing::Fake::Query)
some_query.session
=> #<Cassie::Testing::Fake::Session::Session:0x007fd03e29a688>

another_query = SomeQuery.new
another_query.session
# => this is not a fake session
```

Stubbing a class will apply to all objects of that class.

```ruby
SomeQuery.extend(Cassie::Testing::Fake::Query)
SomeQuery.session
=> #<Cassie::Testing::Fake::Session::Session:0x007fd03e29a688>
SomeQuery.new.session
=> #<Cassie::Testing::Fake::Session::Session:0x007fd03e29a688>
```

If you're testing query extensions you have created, it may be more DRY to use a `Cassie::FakeQuery`, which is simply a child of `Cassie::Query` that has already extended `Cassie::Testing::Fake::Query`.

```ruby
class TestQuery < Cassie::FakeQuery
end
TestQuery.session
=> #<Cassie::Testing::Fake::Session::Session:0x007fd03e29a688>
```

As shown above, query fakes uses a fake session, which provides a few useful features in additon to allowing mock execution:

##### Accessing the last statement executed

```ruby
some_query.execute

some_query.session.last_statement
=> #<Cassandra::Statements::Simple:0x3ffde09930b8 @cql="SELECT * FROM users LIMIT 1;" @params=[]>
```

##### Mocking rows returned in result from query execution

```ruby
some_query.session.rows = [{id: 1, username: "eprothro"}]

some_query.fetch
=> [#<Struct id=1, username="eprothro">]
```
