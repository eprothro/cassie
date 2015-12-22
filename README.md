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

Queries defined on the fly like this tend to create debt for an application in the long term. They:
  * create gaps in test coverage
  * resist documentation
  * resist refactoring

Your application queries represent behavior, `cassie-queries` is structured to help you create query classes that are reusable, testable and maintainable, so you can sleep better at night.

```ruby
# Some PORO user model
user = User.new(username: username)

MyInsertionQuery.new.insert(user)
```
<pre><b>
(1.2ms) INSERT INTO users_by_username (id, username) VALUES (?, ?); [["uuid()", "eprothro"]]
</b></pre>

```ruby
class MyInsertionQuery < Cassie::Query
  # Include some code that defines a `.session` class method
  # that returns a valid Cassandra Session object for the
  # keyspace that needs to be operated on
  include MyCassandraSession

  insert :users_by_username do |u|
    u.id,
    u.username
  end

  def id
    "uuid()"
  end
end
```

CQL algebra is less complex than with SQL. So, rather than introducing a query abstraction layer (e.g. something like [arel](https://github.com/rails/arel)), `cassie-queries` provides a lightweight CQL DSL to codify your CQL queries.

```sql
  SELECT *
  FROM posts_by_author_category
  WHERE author_id = ?
  AND category = ?;
```
```ruby
  select :posts_by_author_category
  where :author_id, :eq
  where :category, :eq
```

This maintains the clarity of the CQL, but allows you to be expressive by using additional features and not having get crazy with string manipulation.

#### Conditional relations

```ruby
  select :posts_by_author_category

  where :author_id, :eq
  where :category, :eq, if: "category.present?"
```
or
```ruby
  select :posts_by_author_category

  where :author_id, :eq
  where :category, :eq, if: :filter_by_category?

  def filter_by_category?
    #true or false, as makes sense for your query
  end
```

#### Object Mapping
For Data Modification Queries (`insert`, `update`, `delete`), mapping binding values from an object is supported.

```ruby
class UpdateUserQuery < Cassandra::Query
  include CassandraSession

  update :users_by_id do |q|
    q.set :phone
    q.set :email
    q.set :address
    q.set :username
  end

  where :id, :eq

  map_from :user
```
Allowing you to pass an object to the modification method, and binding values will be retrieved from the object

```ruby
user
=> #<User:0x007ff8895ce660 @id=6539, @phone="+15555555555", @email="etp@example.com", @address=nil, @username= "etp">
UpdateUserQuery.new.update(user)
```
<pre><b>
(1.2ms) UPDATE users_by_id (phone, email, address, username) VALUES (?, ?, ?, ?) WHERE id = ?; [["+15555555555", "etp@example.com", nil, "etp", 6539]]
</b></pre>

#### Cursored paging (WIP)

Read about [cursored pagination](https://www.google.com/webhp?q=cursored%20paging#safe=off&q=cursor+paging) if unfamiliar with concept and how it optimizes paging through frequently updated data sets and I/O bandwidth.

```ruby
class MyPagedQuery < Cassie::Query
  include CassandraSession

  select :events_by_user

  where :user_id, :eq

  max_cursor :event_id
  since_cursor :event_id
end
```

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

The `cursored_by` helper can be used as shorthand for defining these relations for which you wish to use cursors.
```ruby
class MyPagedQuery < Cassie::Query
  include CassandraSession

  select :events_by_user

  where :user_id, :eq

  cursored_by :event_id
end
```

#### Prepared statements

A `Cassie::Query` will use prepared statements by default, cacheing prepared statements across all Cassie::Query objects, keyed by the bound CQL string.


If you don't want to use a prepared statement, you may disable the `.prepare` class option.

```ruby
class MySpecialQuery < Cassie::Query
  include CassandraSession

  select :users_by_some_value do
    where :bucket
    where :some_value, :in
  end

  # the length of `some_values` that will be passed in
  # is highly variable, so we don't want to incur the
  # cost of preparing a statement for each unique length
  self.prepare = false
end
```
```
query = MySpecialQuery.new

# will not prepare statement
set_1 = query.fetch([1, 2, 3])
# will not prepare statement
set_2 = query.fetch([7, 8, 9, 10, 11, 12])
```

#### Unbound statements

override `#statement`


#### Logging

You may set the log level to debug to log execution to STDOUT (by default).

```ruby
Cassie::Queries::Logging.logger.level = Logger::DEBUG
```
```ruby
SelectUserByUsernameQuery.new('some_user').execute
(2.9ms) SELECT * FROM users_by_username WHERE username = ? LIMIT 1; [["some_user"]]
```
