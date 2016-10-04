# Cassie Queries

`cassie` query classes aim to provide a query interface that is

* Easy to use
* Easy to understand (and thus maintain)
* Easy to test
* Works well with a data mapper and/or repository design pattern

### Usage

You might expect to see class methods allowing queries to be built like such:

```
Cassie.insert(:users_by_username,
              "id = #{some_id}",
              username: some_username)
```

Queries defined on the fly like this tend to create debt for an application in the long term. They:
  * create gaps in test coverage
  * resist documentation
  * resist refactoring

Application queries represent distinct application behavior, `cassie` queries are designed to help create query classes that are reusable, testable and maintainable (so you can sleep better at night).

```ruby
# Some PORO user model
user = User.new(username: username)

MyInsertionQuery.new(user: user).execute
```
<pre><b>
(1.2ms) INSERT INTO users_by_username (id, username) VALUES (?, ?); [["uuid()", "eprothro"]]
</b></pre>

```ruby
class MyInsertionQuery < Cassie::Modification

  insert_into :users_by_username do |u|
    u.set :id,
    u.set :username
  end

  def id
    "uuid()"
  end
end
```

CQL algebra is less complex than with SQL. So, rather than introducing a query abstraction layer (e.g. something like [arel](https://github.com/rails/arel)), `cassie` queries provide a lightweight CQL DSL to codify your CQL queries.

```sql
  SELECT *
  FROM posts_by_author_category
  WHERE author_id = ?
  AND category = ?
  LIMIT 30;
```
```ruby
  select_from :posts_by_author_category
  where :author_id, :eq
  where :category, :eq
  limit 30
```

This maintains the clarity of your CQL, allowing you to be expressive, but still use additional features without having get crazy with string manipulation.

#### Query Classes

CQL statements are used for 3 different kinds of queries:
* data definition (e.g. `ALTER`, `CREATE TBLE`, etc.)
* data modification (e.g. `INSERT`, `UPDATE`, `DELETE`)
* data query (e.g. `SELECT`)

Cassie provides 3 base classes for these 3 kinds of queries. Subclass `Cassie::Definition`, `Cassie::Modification`, and `Cassie::Query` to define your applicaiton query classes.


#### Dynamic term values

```ruby
select_from :posts_by_author

where :user_id, :eq
```

Defining a CQL relation in a cassie query (the "where") creates a setter and getter for that relation. This allows the term value to be set for a particular query instance.

```ruby
query.user_id = 123
query.fetch
=> [#<Struct user_id=123, id="some post id">]
```

<pre><b>
(2.9ms) SELECT * FROM posts_by_author WHERE user_id = ? LIMIT 1; [[123]]
</b></pre>

These methods are defined as attr_accessors. The underlying instance values can be treated as such.

```ruby
select_from :posts_by_author

where :user_id, :eq

def author=(user)
  @user_id = user.id
end
```

```ruby
query.author = User.new(id: 123)
query.fetch
=> [#<Struct user_id=123, id="some post id">]
```

<pre><b>
(2.9ms) SELECT * FROM posts_by_author WHERE user_id = ? LIMIT 1; [[123]]
</b></pre>

A different name can be defined for the setter/getter:

```ruby
select_from :posts_by_author

where :user_id, :eq, value: :author_id
```

```ruby
query.author_id = 123
query.fetch
=> [#<Struct user_id=123, id="some post id">]
```

<pre><b>
(2.9ms) SELECT * FROM posts_by_author WHERE user_id = ? LIMIT 1; [[123]]
</b></pre>

#### Conditional relations

```ruby
  select_from :posts_by_author_category

  where :author_id, :eq
  where :category, :eq, if: "category.present?"
```

or

```ruby
  select_from :posts_by_author_category

  where :author_id, :eq
  where :category, :eq, if: :filter_by_category?

  def filter_by_category?
    #true or false, as makes sense for your query
  end
```

#### Column Selection

```ruby
  select_from :posts_by_author do |t|
    t.select :post_id
    t.select writetime(:post_id)
  end
```
which is the same as
```ruby
  select_from :posts_by_author

  select :post_id
  select writetime(:post_id)
```

`count`, `write_time` (also aliased as `writetime`), and `ttl` selector helpers are available.

```ruby
  select_from :posts_by_author

  select count
```
```
=> SELECT COUNT(*) FROM posts_by_author;
```
```ruby
  select_from :posts_by_author

  select :id
  select ttl(:popular)
  select writetime(:popular), as: :created_at
```
```
=> SELECT id, TTL(popular), WRITETIME(popular) AS created_at FROM posts_by_author;
```
#### Custom terms

Set custom assignments and relations with the same DSL.

```ruby
insert_into :posts

set :id, term: "now()"
```

```ruby
insert_into :posts

set :published_at, "toTimestamp(now())"
```

```ruby
select :posts

where :id, :gteq, term: "minTimeuuid(?)", value: :window_min_timestamp

def window_min_timestamp
  '2013-02-02 10:00+0000'
end
```

#### Consistency configuration

The [consistency level](http://datastax.github.io/ruby-driver/v2.1.6/api/cassandra/#consistencies-constant) for a query is determined by your `Cassie::configuration` by default, falling to back to the `Cassandra` default if none is given.

```ruby
Cassie.configuration[:consistency]
=> nil

Cassie.cluster.instance_variable_get(:@execution_options).consistency
=> :one
```

Cassie queries allow for a consistency level defined on the object, subclass, then base class levels. If one is found, it will override the `Cassandra` default when the query is executed.

```ruby
  select_from :posts_by_author_category

  where :author_id, :eq
  where :category, :eq, if: :filter_by_category?

  def filter_by_category?
    #true or false, as makes sense for your query
  end

  def consistency
    #dynamically determine a query object's consistency level
    if filter_by_category?
      :quorum
    else
      super
    end
  end
```

```ruby
  select_from :posts_by_author_category

  where :author_id, :eq
  where :category, :eq

  consistency :quorum
```

```ruby
# lib/tasks/interesting_task.rake
require_relative "interesting_worker"

task :interesting_task do
  Cassandra::Query.consistency = :all

  InterestingWorker.new.perform
end
```

#### Finders

To avoid confusion with ruby `Enumerable#find` and Rails' specific `find` functionality, Cassie::Query opts to use `fetch` and explict `fetch_first` or `fetch_first!` methods.

##### `fetch`

Executes the query; returns an enumeration of results.

```
UsersByResourceQuery.new.fetch(resource: some_resource).to_a
=> [#<User id=:123, username=:eprothro>, #<User id=:456, username=:tenderlove>]
```

##### `fetch_first` and `fetch_first!`

Executes the query, temporarily limited to 1 result; returns a single result. Bang version raises if no result is found.

```
UsersByUsernameQuery.new.fetch_first(username: "eprothro").username
=> "eprothro"
```

```
UsersByUsernameQuery.new.fetch_first(username: "ActiveRecord")
=> nil
```

```
UsersByUsernameQuery.new.fetch_first!(username: "active record").username
Cassie::Statements::RecordNotFound: CQL row does not exist
```

##### BatchedFetching

Similar to [Rails BatchedFetching](http://guides.rubyonrails.org/v4.2/active_record_querying.html#retrieving-multiple-objects-in-batches), Cassie allows efficient batching of `SELECT` queries.

###### `fetch_each`

```
UsersQuery.new.fetch_each do |user|
  # only 1000 queried and loaded at a time
end
```

```
UsersQuery.new.fetch_each(batch_size: 500) do |user|
  # only 500 queried and loaded at a time
end
```

```
UsersQuery.new.fetch_each.with_index do |user, index|
  # Enumerator chaining without a block
end
```

###### `fetch_in_batches`

```
UsersQuery.new.fetch_in_batches do |users_array|
  # only 1000 queried and at a time
end
```

```
UsersQuery.new.fetch_in_batches(batch_size: 500) do |users_array|
  # only 500 queried and at a time
end
```

```
UsersQuery.new.fetch_in_batches.with_index do |group, index|
  # Enumerator chaining without a block
end
```

#### Deserialization

For Selection Queries, records are deserialized as anonymous structs by default. Each field returned from the database will have an accessor.

```ruby
UsersByUsernameQuery.new.fetch(username: "eprothro")
#=> [#<Struct id=:123, username=:eprothro>]

UsersByUsernameQuery.new.fetch_first(username: "eprothro").username
=> "eprothro"
```

Most applications will want to override `build_result` to construct more useful domain objects

```
class UsersByUsernameQuery < Cassie::Query

  select_from :users_by_username

  where :username, :eq

  def build_result(row)
    User.new(row)
  end
end
```

```ruby
UsersByUsernameQuery.new.fetch_first(username: "eprothro")
=> #<User:0x007fedec219cd8 @id=123, @username="eprothro">
```

#### Object Mapping

For Data Modification Queries (inserts, updates, deletes), mapping binding values from a domain object is supported.

```ruby
class UpdateUserQuery < Cassandra::Modification

  update :users_by_id do |q|
    q.set :phone
    q.set :email
    q.set :address
    q.set :username
  end

  where :id, :eq

  map_from :user
```

This allows a domain object to be passed to the modification object and have binding values retrieved from the object.

```ruby
user
=> #<User:0x007ff8895ce660 @id=6539, @phone="+15555555555", @email="etp@example.com", @address=nil, @username= "etp">
UpdateUserQuery.new(user: user).execute
```

<pre><b>
(1.2ms) UPDATE users_by_id (phone, email, address, username) VALUES (?, ?, ?, ?) WHERE id = ?; [["+15555555555", "etp@example.com", nil, "etp", 6539]]
</b></pre>

This mapping is done in a way akin to delegation, so the behavior can be changed easily for one or more accessors.

```
class UpdateUserQuery < Cassandra::Modification

  update :users_by_id do |q|
    q.set :phone
    q.set :email
    q.set :address
    q.set :username
  end

  where :id, :eq

  map_from :user

  def username
    user.username.downcase
  end
```
```ruby
user
=> #<User:0x007ff8895ce660 @id=6539, @phone="+15555555555", @email="etp@example.com", @address=nil, @username= "ETP">
UpdateUserQuery.new(user: user).execute
```

<pre><b>
(1.2ms) UPDATE users_by_id (phone, email, address, username) VALUES (?, ?, ?, ?) WHERE id = ?; [["+15555555555", "etp@example.com", nil, "etp", 6539]]
</b></pre>


#### Cursored paging

Read about [cursored pagination](https://www.google.com/webhp?q=cursored%20paging#safe=off&q=cursor+paging) if unfamiliar with concept and how it optimizes paging through frequently updated data sets and I/O bandwidth.

```ruby
class MyPagedQuery < Cassie::Query

  select_from :events_by_user

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

The `cursor_by` helper can be used as shorthand for defining these relations for which you wish to use cursors.
```ruby
class MyPagedQuery < Cassie::Query

  select_from :events_by_user

  where :user_id, :eq

  cursor_by :event_id
end
```

#### Prepared statements

A `Cassie::Query` will use prepared statements by default, cacheing prepared statements across all Cassie::Query objects, keyed by the bound CQL string.


To not use prepared statements for a particular query, disable the `.prepare` class option.

```ruby
class MySpecialQuery < Cassie::Query

  select_from :users_by_some_value do
    where :bucket
    where :some_value, :in
  end

  # the length of `some_values` that will be passed in
  # is highly variable, so we don't want to incur the
  # cost of preparing a statement for each unique length
  self.prepare = false
end
```

```ruby
query = MySpecialQuery.new

# will not prepare statement
set_1 = query.fetch([1, 2, 3])
# will not prepare statement
set_2 = query.fetch([7, 8, 9, 10, 11, 12])
```

#### Unbound statements

Cassie Query features are built around bound statements. However, we've tried to keep a simple ruby design in place to make custom behavior easier. If you want to override the assumption of bound statements, simply override `#statement`, returnign something that a `Cassandra::Session` can execute.

```ruby
class NotSureWhyIWouldDoThisButHereItIsQuery < Cassie::Query
  def statement
    "SELECT * FROM users WHERE id IN (1,2,3);"
  end
end
```

> Note: unbound queries like this are vulnerable againt injection attacks.

#### Logging

Cassie Query objects use the Cassie logger unless overridden. This logs to STDOUT by default. Set any log stream you wish.

```ruby
  Cassie.logger = my_app.config.logger
```

Set the log level to `debug` in order to log execution details.

```ruby
Cassie::Query.logger.level = Logger::DEBUG
```

#### Execution Time

Cassie Queries instrument execution time as `cassie.cql.execution` and logs a debug message.

```ruby
SelectUserByUsernameQuery.new('some_user').execute
(5.5ms) SELECT * FROM users_by_username WHERE username = ? LIMIT 1; ["some_user"] [LOCAL_ONE]
```
This measures the time to build the CQL query (statement and bindings), transmit the query to the cassandra coordinator, receive the result from the cassandra coordinator, and have the cassandra ruby driver build the ruby representation of the results. It does not include the time it takes for the Cassie Query to build its resource objects.

#### Record Loading

Cassie Queries instrument record building as `cassie.deserialize` and logs a debug message.

```ruby
SelectUserByUsernameQuery.new('some_user').fetch
(5.5ms) SELECT * FROM users_by_username WHERE username = ? LIMIT 1; ["some_user"] [LOCAL_ONE]
(0.2ms) 1 record built from Cassandra query result
```

This measures the time it takes Cassie to build the records (e.g. your domain objects) and is in addition to the execution time.

> total fetch time = `cassie.cql.execution` time + `cassie.deserialize` time