# cassie

This is in alpha stages. We're iterating to provide important features in a lightweight and loosely coupled way.

Cassie provides support for the components most applications need to work with a Cassandra persistence layer:

* Database configuration and efficient session management
* Versioned schema migrations
* Query classes
* Test harnessing

### Installation

```ruby
# Gemfile
gem 'cassie', '~> 1.0.0.alpha'
```
or
```bash
$ gem install cassie --pre
```

### Database Configuration

Cassie provies database connection configuration (e.g. cluster and session) per environment. A default YAML back-end is provided.

```
cassie config:generate
```

See the [`Cassie::Configuration` README](./lib/cassie/configuration/README.md#readme) for more on features and usage.

### Session Management

Essence of features/usage.

Link to more info in the `configuration` README.

### Versioned Migrations

Essence of features/usage.

Link to more info in the `migrations` README.

### Query Classes

Cassie provides Query Classes to manage interactions to the database. This approach offers easier testing as well as better clarity and maintainability.
Inherit query classes from Cassie::Query and construct your query with a simple CQL DSL.

```
class UserByUsernameQuery < Cassie::Query

  select :users_by_username

  where :username, :eq

  def build_resource(row)
    User.new(row)
  end
end
```

```ruby
UserByUsernameQuery.new.find(username: "eprothro")
=> #<User:0x007fedec219cd8 @id=123, @username="eprothro">
```

See the [`Cassie::Query` README](./lib/cassie/queries/README.md#readme) for more on features and usage.

### Test Harnessing

Essence of features/usage.

Link to more info in the `testing` README.