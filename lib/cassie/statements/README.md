# Cassie Queries

`cassie` query classes aim to provide a query interface that is

* Easy to use
* Easy to understand (and thus maintain)
* Easy to test
* Compatible with a data mapper and/or repository design pattern

### Usage

You might expect to see class methods allowing queries to be built like such:

```ruby
Cassie.insert(:users_by_username,
              "id = #{some_id}",
              username: some_username)
```
or
```
Cassie.select_from(:table)
      .where(id: some_id)
      .where(username: some_username)
```

Queries defined on the fly like this tend to create debt for an application in the long term. They:
  * create gaps in test coverage
  * lack clear documentation
  * resist refactoring

Application queries represent distinct application behavior, `cassie` queries are designed to help create query classes that are reusable, testable and maintainable (so you can sleep better at night).

```ruby
# Some user model
user = User.new(username: username)

MyInsertionQuery.new(user: user).execute
```
<pre><b>
(1.2ms) INSERT INTO users_by_username (id, username) VALUES (?, ?); [["uuid()", "eprothro"]]
</b></pre>

```ruby
class MyInsertionQuery < Cassie::Modification

  insert_into :users_by_username

  set :id
  set :username

  def id
    Cassandra::TimeUuid::Generator.new.now
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

This maintains the clarity of CQL, allowing code to be expressive, but still use additional features without having get crazy with string manipulation.

#### Query Classes

CQL statements are used for 3 different kinds of queries:
* data definition (e.g. `ALTER`, `CREATE TBLE`, etc.)
* data modification (e.g. `INSERT`, `UPDATE`, `DELETE`)
* data query (e.g. `SELECT`)

Cassie provides 3 base classes for these 3 kinds of queries. Subclass `Cassie::Definition`, `Cassie::Modification`, and `Cassie::Query` to define your applicaiton query classes.

##### `Cassie::Definition`
  Only includes the core functionality for statement execution:
    * connection methods (`session`, `keyspace`)
    * `execute` method
    * `result` attribute, populated by execution
    * instrumentation and logging of execution

  A typical use of a `Definition` subclass would be for a static DDL query. Override the `statement` method, returning a CQL statement (`String` or `Cassandra::Statements`) that will be executed with the `Cassandra` driver.

##### `Cassie::Modification`
  Includes core functionality for prepared statement execution.

  * Adds DSL for `insert_into`, `update`, and `delete_from` statement types
  * Adds support for automatically mapping values for assignments from a domain object

##### `Cassie::Query`
  Includes core functionality for prepared statement execution.

  * Adds DSL for `select_from` statement type
  * Adds `fetch` and `fetch_first` methods for executing and getting results with a single method call
  * Adds support for deserializing domain objects from Cassandra rows
  * Adds support for paging through results with cursors
  * Adds support for fetching large data sets in memory-efficient batches


#### Relations (`where` clauses)

```ruby
select_from :posts_by_author

where :user_id, :eq
```

Defining a CQL relation (the `where`) in a cassie query class creates a setter and getter for that relation. This allows the value for the term to be set for a particular query instance.

```ruby
query.user_id = 123
query.fetch
#=> [#<Struct user_id=123, id="some post id">]
```

<pre><b>
(2.9ms) SELECT * FROM posts_by_author WHERE user_id = ? LIMIT 1; [[123]]
</b></pre>

These methods are defined as simple attr_accessors. The underlying instance values can be treated as such.

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
#=> [#<Struct user_id=123, id="some post id">]
```

<pre><b>
(2.9ms) SELECT * FROM posts_by_author WHERE user_id = ? LIMIT 1; [[123]]
</b></pre>

A different name can be defined for the value's setter/getter:

```ruby
select_from :posts_by_author

where :user_id, :eq, value: :author_id
```

```ruby
query.author_id = 123
query.fetch
#=> [#<Struct user_id=123, id="some post id">]
```

<pre><b>
(2.9ms) SELECT * FROM posts_by_author WHERE user_id = ? LIMIT 1; [[123]]
</b></pre>

Relations can be conditionally evaluated:

```ruby
  select_from :posts_by_author_category

  where :author_id, :eq
  where :category, :eq, if: :filter_by_category?

  def filter_by_category?
    #true or false, as makes sense for your query
  end
```
This can be overdone; it's recommended that one query class be in charge of one kind of query. Avoid query classes that can do too much!


#### Values and Assignments (`set`)

Set values (for inserts) and assignments (for updates) with the same `set` method. Similar to relations defined with `where`, assignments provide simple getters and setters.

```ruby
class InsertUserQuery < Cassandra::Modification

  insert :users_by_id

  set :id
  set :username
end
```

```ruby
class UpdateUsernameQuery < Cassandra::Modification

  insert :users_by_id

  set :username

  where :id, :eq
end
```
```ruby
query = UpdateUserQuery.new(id: current_user.id)
query.username = 'eprothro'
query.execute
#=> true
```

Mapping assignemtnt values from a domain object is supported.

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

This allows a domain object to be set for the modification object and have assignment values retrieved from that object.

```ruby
user
#=> #<User:0x007ff8895ce660 @id=6539, @phone="+15555555555", @email="etp@example.com", @address=nil, @username= "etp">
UpdateUserQuery.new(user: user).execute
```

<pre><b>
(1.2ms) UPDATE users_by_id (phone, email, address, username) VALUES (?, ?, ?, ?) WHERE id = ?; [["+15555555555", "etp@example.com", nil, "etp", 6539]]
</b></pre>

This mapping is done in a way akin to delegation, so the behavior can be changed easily for one or more accessors by overriding the getter.

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
#=> #<User:0x007ff8895ce660 @id=6539, @phone="+15555555555", @email="etp@example.com", @address=nil, @username= "ETP">
UpdateUserQuery.new(user: user).execute
```

<pre><b>
(1.2ms) UPDATE users_by_id (phone, email, address, username) VALUES (?, ?, ?, ?) WHERE id = ?; [["+15555555555", "etp@example.com", nil, "etp", 6539]]
</b></pre>

The above examples use positional terms (e.g. the term is '?' in the statement). The assignement's term can be defined explicitly.

```ruby
insert_into :posts

set :id, term: "now()"
```

```ruby
update :post_counts

set :comments_count, "comments_count + 1"

non_idempotent
```

A value will be fetched and placed as an argument in the statement if the provided term includes a positional marker ('?').

```ruby
select :posts

where :id, :gteq, term: "minTimeuuid(?)", value: :window_min_timestamp

def window_min_timestamp
  '2013-02-02 10:00+0000'
end
```

> Note: The `term` option should be used with care. Using it innapropriately could result in inefficient use of prepared statements, and/or leave you potentially vulnerable to injection attacks.


#### Column Selection (`select`)

By default, all columns will be selected (e.g. '*'). Specify a column for selection with `select`.

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
#=> SELECT COUNT(*) FROM posts_by_author;
```

Aliasing is supported with the `as` option.
```ruby
  select_from :posts_by_author

  select :id
  select ttl(:popular)
  select writetime(:popular), as: :created_at
```
```
#=> SELECT id, TTL(popular), WRITETIME(popular) AS created_at FROM posts_by_author;
```
Arbitrary strings are supported as well in case the DSL gets in the way.

```ruby
  select_from :posts_by_author

  select 'cowboy, coder'
```
```
#=> SELECT cowboy, coder FROM posts_by_author;
```

#### Column Deletion (`column`)

By default, all columns for specified CQL rows will be deleted. Identify a subset of columns for tombstoning with `column`.

```ruby
  delete_from :authors_by_id
  column :nickname
  where :id, :eq
```
```
#=> DELETE nickname FROM authors_by_id where id = 123;
```

#### Execution and Result

Executing a `Cassie::Query` populates the `result` attribute.

```ruby
query.execute
# => true
query.result.class
# => Cassie::Statements::Results::QueryResult
```

The result lazily enumerates domain objects
```ruby
query.execute
#=> true
query.result.each
#=> #<[#< Struct id=:123, username=:eprothro >]>
```

The result has a `first!` method that raises if no result is available
```ruby
query.execute
#=> true
query.result.first!
Cassie::Statements::RecordNotFound: CQL row does not exist
```

The result delegates to the `Cassandra::Result`.
```ruby
query.result.execution_info
#=> #<Cassandra::Execution::Info:0x007fb404b51390 @payload=nil, @warnings=nil, @keyspace="cassie_test", @statement=#<Cassandra::Statements::Bound:0x3fda0258dee8 @cql="SELECT * FROM users_by_username LIMIT 500;" @params=[]>, @options=#<Cassandra::Execution::Options:0x007fb404b1b880 @consistency=:local_one, @page_size=10000, @trace=false, @timeout=12, @serial_consistency=nil, @arguments=[], @type_hints=[], @paging_state=nil, @idempotent=false, @payload=nil>, @hosts=[#<Cassandra::Host:0x3fda02541390 @ip=127.0.0.1>], @consistency=:local_one, @retries=0, @trace=nil>
query.result.rows
#=> #<Enumerator: [{"id"=>123, "username"=>"eprothro"}]>
```

#### Finders

To avoid confusion with ruby `Enumerable#find` and Rails' specific `find` functionality, Cassie::Query opts to use `fetch` and explict `fetch_first` or `fetch_first!` methods.

##### `fetch`

Calls setters for any opts passed, executes the query, and returns the result.

```ruby
UsersByResourceQuery.new.fetch(resource: some_resource).to_a
#=> [#<User id=:123, username=:eprothro>, #<User id=:456, username=:tenderlove>]
```

##### `fetch_first` and `fetch_first!`

Temporarily limits the query to 1 result; returns a single domain object. Bang version raises if no row is found.

```ruby
UsersByUsernameQuery.new.fetch_first(username: "eprothro")
#=> #<User id=:123, username=:eprothro>
```

```ruby
UsersByUsernameQuery.new.fetch_first(username: "ActiveRecord")
#=> nil
```

```ruby
UsersByUsernameQuery.new.fetch_first!(username: "active record").username
Cassie::Statements::RecordNotFound: CQL row does not exist
```

##### BatchedFetching

Similar to [Rails BatchedFetching](http://guides.rubyonrails.org/v4.2/active_record_querying.html#retrieving-multiple-objects-in-batches), Cassie allows efficient batching of `SELECT` queries.

###### `fetch_each`

```ruby
UsersQuery.new.fetch_each do |user|
  # only 1000 queried and loaded at a time
end
```

```ruby
UsersQuery.new.fetch_each(batch_size: 500) do |user|
  # only 500 queried and loaded at a time
end
```

```ruby
UsersQuery.new.fetch_each.with_index do |user, index|
  # Enumerator chaining without a block
end
```

###### `fetch_in_batches`

```ruby
UsersQuery.new.fetch_in_batches do |users_array|
  # only 1000 queried and at a time
end
```

```ruby
UsersQuery.new.fetch_in_batches(batch_size: 500) do |users_array|
  # only 500 queried and at a time
end
```

```ruby
UsersQuery.new.fetch_in_batches.with_index do |group, index|
  # Enumerator chaining without a block
end
```

#### Deserialization

For `Cassie::Query` classes, records are deserialized as anonymous structs by default. Each field returned from the database will have an accessor.

```ruby
UsersByUsernameQuery.new.fetch(username: "eprothro")
#=> [#<Struct id=:123, username=:eprothro>]

UsersByUsernameQuery.new.fetch_first!(username: "eprothro").username
#=> "eprothro"
```

Most applications will want to provide a `build_result` method to construct more useful domain objects

```ruby
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
#=> #<User:0x007fedec219cd8 @id=123, @username="eprothro">
```

`build_results` may be provided as well to define custom definition of the enumeration of rows returned from Cassandra.

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

The `cursor_by` helper can be used as shorthand for defining these relations for which you wish to use cursors. The page size can be defined on the class
```ruby
class MyPagedQuery < Cassie::Query

  select_from :events_by_user

  where :user_id, :eq

  cursor_by :event_id

  page_size 25
end
```

> Note: the `page_size` class and instance setters are simply convenience aliases for associated `limit` methods.

#### Synthetic partitioning

Managing partition size is critical with a Cassandra physical layer.

When a partition defined by the conventional partition key may grow larger than [recommended](https://docs.datastax.com/en/landing_page/doc/landing_page/planning/planningPartitionSize.html), adding a synthetic partition key is one viable strategy to implment.
This synthetic partition key splits the entire conceptual partition into multiple logical / physical partitions.

A logical model with synthetic partitioning:
```
+------------------+
| records_by_owner |
+------------------+
| owner_id      K  |
| bucket        K  |
| record        C↑ |
| ...              |
+------------------+
```

Visualizing partitions with synthetic partitioning:
```
+------------------------------------------------------+
|| owner_id_1 || record  | record  |   ...   | record  |
||   bucket 0 || 1       | 2       |         | 100,000 |
+------------------------------------------------------+

+------------------------------------------------------+
|| owner_id_1 || record  | record  |   ...   | record  |
||   bucket 1 || 100,001 | 100,002 |         | 200,000 |
+------------------------------------------------------+
```

Cassie Queries provides support for selecting data sets that span these physical partitions (e.g. {99,990..100,090}).

Set up partition linking to accomplish this:

```ruby
class RecordsByOwnerQuery < Cassie::Query
  attr_accessor :min_record, :owner

  select_from :records_by_owner

  where :owner_id, :eq
  where :bucket, :eq
  where :record, :gteq, value: :min_record

  limit 100

  link_partitions :bucket, :ascending, [0, :last_bucket]

  def owner_id
    owner.id
  end

  def bucket
    1
  end

  protected

  def last_bucket
    owner.buckets
  end
end
```
```ruby
RecordsByOwnerQuery.new(owner: owner, min_record: 99,990).fetch.map(&:record)
(2.9ms) SELECT * FROM records_by_owner WHERE owner_id = ? AND bucket = ? AND record >= ? LIMIT 100; [123, 0, 99990]
(2.9ms) SELECT * FROM records_by_owner WHERE owner_id = ? AND bucket = ? AND record >= ? LIMIT 100; [123, 1, 99990]
#=> [99990, 99991, ..., 100089, 100090]
```

The first partition queried is defined within the query class (bucket 0). The linking policy handles recognizing the end of the first partition has been reached, issuing the second query for the second partition (bucket 1), and combining the results from both queries.

By default, this works for ascending and descending orderings when paging in the same order as the clustering order; it also works with cursoring.

Custom policies can be defined by setting `Query.partition_linker` for more complex schemas. See the `SimplePolicy` source for an example.

#### Consistency configuration

The [consistency level](http://datastax.github.io/ruby-driver/api/cassandra/#consistencies-constant) for a query is determined by your `Cassie::configuration` by default, falling to back to the `Cassandra` default if none is given.

```ruby
Cassie.configuration[:consistency]
#=> nil

Cassie.cluster.instance_variable_get(:@execution_options).consistency
#=> :one
```

Cassie queries allow for a consistency level to be defined on the object, subclass, base class, and global levels. If none is found, it will default to the `cluster` default when the query is executed.

Object writer:
```ruby
  query = MyQuery.new
  query.consistency = :all
  query.execute
```
Override Object reader:
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

Class writer
```ruby
  select_from :posts_by_author_category

  where :author_id, :eq
  where :category, :eq

  consistency :quorum
```

Cassie query classes
```ruby
# lib/tasks/interesting_task.rake
require_relative "interesting_worker"

task :interesting_task do
  Cassie::Modification.consistency = :all

  InterestingWorker.new.perform
end
```

Cassie global default
```ruby
# lib/tasks/interesting_task.rake
require_relative "interesting_worker"

task :interesting_task do
  Cassie::Statements.default_consistency = :all

  InterestingWorker.new.perform
end
```

#### Idempotentcy configuration

Cassie statements are set as [idempotent](http://datastax.github.io/ruby-driver/api/cassandra/statements/simple/) by default. This setting influences how [retries](http://datastax.github.io/ruby-driver/features/retry_policies/) are handled.

Mark queries that are not idempotent, so that the driver won't automatically retry for certain failure scenarios.

Similar to other settings, there is a `Cassie::Statements.default_idempotency`, class level setting, and object level setting.

```ruby
class MyQuery < Cassie::Modification
  update :counter_table

  set :counter, term: :counter_val

  def counter_val
    "counter + 1"
  end
end
```
```
MyQuery.idempotent?
# => true
```

```ruby
class MyQuery < Cassie::Modification
  update :counter_table

  set :counter, term: :counter_val

  non_idempotent

  def counter_val
    "counter + 1"
  end
end
```
```
MyQuery.idempotent?
# => false
```

#### Prepared statements

A `Cassie::Query` will use prepared statements by default, cacheing prepared statements across all `Query`, `Modification`, and `Definition` objects, keyed by the unbound CQL string.

To disable prepared statements for a particular query, disable the `.prepare` class option.

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

#### Allowing Filtering

For select statements, allowing filtering is supported.

```ruby
class IveReallyThoughtThisOutQuery < Cassie::Query

  select_from :users_by_id

  where :rank, :gt

  attr_accessor :rank

  allow_filtering
end
```

Assuming `rank` is a field for which a ranging query requires [Cassandra filtering](http://www.datastax.com/dev/blog/allow-filtering-explained-2), the statement will now be valid.
```
query = IveReallyThoughtThisOutQuery.new(rank: rank)
query.to_cql
=> "SELECT * FROM users_by_id WHERE rank > 100 ALLOW FILTERING;"
```

Allowing filtering in production is usually a Bad Idea, unless you really are ok with Cassandra loading all CQL rows into memory before filtering down to the requested set.

#### Custom queries

For certain queries, it may be most effective to write CQL directly. The recommended way is to override `cql` and `params`.

```ruby
class MySpecialQuery < Cassandra::Modification
  attr_accessor :resource

  def cql
    "UPDATE my_table SET udt.field = ? WHERE id = ?;"
  end

  def params
    [resource.field, resource.id]
  end
end
```

This preserves using other features and configuration such as consistency, idempotency, prepared statements, etc.

#### Non-positional (unbound) statements

Cassie Query features are built around using bound statements with positional arguments. However, overriding `#statement`, returning something that a `Cassandra::Session` can execute, will result in an unbound, unprepared statement.

```ruby
class MySafeQuery < Cassie::Definition
  def statement
    "ALTER TABLE foo ADD some_column timeuuid static;"
  end
end
```

> Note: unbound queries can be vulnerable to injection attacks. Be careful.

### Development and Debugging

#### `to_cql`

Cassie query objects have a `to_cql` method that handles positional argument interleaving and type conversion to provide CQL that is executable in `cqlsh`.

Keep your queries as perpared/bound statements, but easily copy executable CQL elsewhere.

```
query = UpdateUserQuery.new(user: user)
query.to_cql
=> "UPDATE users_by_id SET phone = '+15555555555', email = 'eprothro@example.com', username = 'eprothro' WHERE id = d331f6b8-8b05-11e6-b61f-2774b0185e07;"
```

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

#### Result Deserialization

Cassie Queries instrument row deserialization as `cassie.deserialize` and logs a debug message.

```ruby
SelectUserByUsernameQuery.new('some_user').fetch_first
(5.5ms) SELECT * FROM users_by_username WHERE username = ? LIMIT 1; ["some_user"] [LOCAL_ONE]
(0.2ms) 1 result deserialized from Cassandra rows
```

This measures the time it takes Cassie to build the results (e.g. your domain objects) and is in addition to the execution time.

> total fetch time = `cassie.cql.execution` time + `cassie.deserialize` time
