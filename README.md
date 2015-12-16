# cassie-queries

This is a work in progress. We're intentionally moving very incrementally, working to provide a library that is

* Easy to use
* Easy to understand (and thus maintain)
* Easy to test
* Works well with a data mapper design pattern

The current interface below, will almost certainly change drastically. Use at your own risk prior to 0.1.0 :).

### Installation

```ruby
# Gemfile
gem cassie-queries
```
or
```ruby
gem install cassie-queries --pre
```

### Usage

What you might expect to see:

```
Cassie.insert(:users_by_username,
              "id = #{some_id}",
              username: some_username)
```

Queries defined on the fly like this tend to not be good for an application in the long term. They:
  * create gaps in test coverage
  * resist documentation
  * resist refactoring

Your application queries represent behavior, `cassie-queries` is structured to help you create the classes that your queries deserve so you can sleep better at night.

```ruby
user = User.new(username: username)
user.generate_id

MyInsertionQuery.new.insert(user)
```

```ruby
class MyInsertionQuery < Cassie::Query
  # some code to define a `MyInsertionQuery.session` class method
  # that returns a valid Cassandra Session object
  include CassandraSession

  insert :users_by_username do
    :id,
    :username
  end

  attr_accessor :user

  def insert(user)
    @user = user
    execute
  end

  def id
    user.id
  end
  def username
    user.username
  end
end
```

### Prepared statements

A `Cassie::Query` will prepare its statement, by default, reusing the prepared statement for all `execution` calls for all objects.

### Unprepared, bound statement
If you don't want to use a prepared statement, you may disable the `.prepare` class option.

If you want to dynamically specify the statement, override the object's `#statement` method with your statement, and ensure the bindings will match the statement.

```ruby
class MySpecialQuery < Cassie::Query
  include CassandraSession

  select :users_by_some_value do
    where :some_value, :in
  end

  self.prepare = false

  attr_reader :some_values

  def fetch(some_values)
    @some_values = some_values
    execute
    result.rows.map { |r| build_user(r) }
  end

  private

  def build_user(row_hash)
    User.new(row_hash)
  end
end
```

```ruby
q = MySpecialQuery.new
set_1 = q.fetch([1, 2, 3])
set_2 = q.fetch([7, 8, 9, 10, 11, 12])
```

### Unbound statements

override `#statement`

### Cursored Paging

Read about [cursored pagination](https://www.google.com/webhp?q=cursored%20paging#safe=off&q=cursor+paging) if unfamiliar with concept and how it optimizes paging through frequently updated data sets and I/O bandwidth.

```ruby
# Imagine a set of id's 100 decreasing to 1
# where the client already has 1-50 in memory.

q = MyPagedQuery.new(page_size: 25, user: current_user)

# fetch 100 - 76
page_1 = q.fetch(max_event_id: nil, since_event_id: 50)
q.next_max_event_id
# => 75

# fetch 75 - 51
page_2 = q.fetch(max_event_id: q.next_max_event_id, since_event_id: 50)
q.next_max_id
# => nil
```

```ruby
class MyPagedQuery < Cassie::Query
  include CassandraSession

  select :events_by_user do
    where :user_id, :eq

    max_cursor :event_id
    since_cursor :event_id
  end

  def fetch(opts={})
    self.max_event_id = opts[:max_event_id]
    self.since_event_id = opts[:since_event_id]
    execute
    result.rows.map { |r| build_user(r) }
  end

  private

  def build_user(row_hash)
    User.new(row_hash)
  end
end
```


### Logging

You may set the log level to debug to log execution to STDOUT (by default).

```ruby
Cassie::Queries::Logging.logger.level = Logger::DEBUG
```
```ruby
SelectUserByUsernameQuery.new('some_user').execute
(2.9ms) SELECT * FROM users_by_username WHERE username = ? LIMIT 1; [["some_user"]]
```
