# Cassie Queries

`cassie` query classes provide query interface that is

* Easy to use
* Easy to understand (and thus maintain)
* Easy to test
* Works well with the data mapper design pattern

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

Your application queries represent behavior, `cassie` queries are structured to help you create query classes that are reusable, testable and maintainable, so you can sleep better at night.

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

CQL algebra is less complex than with SQL. So, rather than introducing a query abstraction layer (e.g. something like [arel](https://github.com/rails/arel)), `cassie` queries provide a lightweight CQL DSL to codify your CQL queries.

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

This maintains the clarity of your CQL, but allows you to be expressive by using additional features and not having get crazy with string manipulation.

#### Dynamic term values

```ruby
select :posts_by_author

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

These methods are plain old attr_accessors, and may be overriden

```ruby
select :posts_by_author

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

A specific name can be provided for the setter/getter:

```ruby
select :posts_by_author

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
For Selection Queries, resources are returned as structs by default for manipulation using accessor methods.

```ruby
UsersByUsernameQuery.new.fetch(username: "eprothro")
=> [#<Struct id=:123, username=:eprothro>]

UsersByUsernameQuery.new.find(username: "eprothro").username
=> "eprothro"
```

Override `build_resource` to construct more useful objects

```
class UsersByUsernameQuery < Cassie::Query
  include CassandraSession

  select :users_by_username

  where :username, :eq

  def build_resource(row)
    User.new(row)
  end
end
```

```ruby
UsersByUsernameQuery.new.find(username: "eprothro")
=> #<User:0x007fedec219cd8 @id=123, @username="eprothro">
```

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


To not use prepared statements for a particular query, disable the `.prepare` class option.

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

```ruby
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
