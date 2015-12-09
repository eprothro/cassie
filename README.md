# cassie-queries
This is a work in progress and it's final interface will probably look nothing like below.
We're intentionally moving very incrementally, working to provide a library that is

* Easy to use
* Easy to understand (and thus maintain)
* Works well with a data mapper design pattern

See the current interface below, which almost certainly will change drastically. Use at your own risk prior to 0.1.0 :).

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

```ruby
class MyQuery < Cassie::Query
  # some code to define a `MyQuery.session` method
  # that returns a valid Cassandra Session object
  include CassandraSession

  cql %(
    INSERT INTO users_by_username
    (id, username)
    VALUES (?, ?);
  )

  attr_accessor :user

  def insert(user)
    @user = user
  end

  def bindings
    [
      user.id,
      user.username
    ]
  end
end
```
```ruby
user = User.new(username: username)
user.generate_id

MyQuery.new.insert(user)
```

### Prepared statements

A `Cassie::Query` will prepare its statement, by default, reusing the prepared statement for all `execution` calls for all objects.

### Unprepared, bound statement
If you don't want to use a prepared statement, you may disable the `.prepare` class option.

If you want to dynamically specify the statement, override the object's `#statement` method with your statement, and ensure the bindings will match the statement.

```ruby
class MySpecialQuery < Cassie::Query
  include CassandraSession

  self.prepare = false

  attr_reader :values

  def fetch(values)
    @values = values
    execute
    result.rows.map { |r| build_user(r) }
  end

  def statement
    %(
      SELECT * from users_by_some_value
      WHERE phone IN (#{binding_markers});"
      )
  end

  def bindings
    values
  end

  private

  def binding_markers
   Array.new(values.count){"?"}.join(", ")
  end

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

Unbound statements are not supported yet (if ever). Get your binding on, thug.

### Logging

You may set the log level to debug to log execution to STDOUT (by default).

```ruby
Cassie::Queries::Logging.logger.level = Logger::DEBUG
```
```ruby
SelectUserByUsernameQuery.new('some_user').execute
(2.9ms) SELECT * FROM users_by_username WHERE username = ? LIMIT 1; [["some_user"]]
```
