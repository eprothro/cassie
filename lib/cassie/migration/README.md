# Cassie Migrations

Cassie provides versioned migrations similar to many existing adapters and frameworks.

Practically speaking, this gives your cluster schmea its own "version" and simplifies upgrading or downgrading the schema.

As such, Cassie uses semantic versioning, where a defined version describes all non-system keyspaces.

Major, minor, and patch versions are used, without support for semantic extensions (prerelase or metadata, ex: 1.0.0.beta).

### Schema Migrations
#### Creating a migration

```
cassie migration:create that_killer_feature --bump minor
=> 0.2.0 - migrations/000_002_000_that_killer_feature.rb
```

```ruby
# migrations/000_002_000_that_killer_feature.rb

Uses the excellend DSL from `cassandra_migrations`.
```

#### Executing migrations

```
cassie migrate
=> roll up to latest version
```

```
cassie migrate 0.2.0
=> roll up to 0.2.0 and stop
```

```
cassie migrate 0.1.9
=> roll back to 0.1.9 and stop
```

#### Rolling back

```
cassie rollback
=> roll back 1 version and stop
```

```
cassie rollback 3
=> roll back 3 versions and stop
```

#### Getting the current version
```
cassie schema:version
+---------+----------------+-------------+---------------------------+
| Version | Description    | Migrated by | Migrated at               |
+---------+----------------+-------------+---------------------------+
| * 0.1.0 | initial schema | eprothro    | 2016-09-08 09:23:54 -0500 |
+---------+----------------+-------------+---------------------------+
```

#### Getting the version history
```
cassie schema:history
+---------+----------------+-------------+---------------------------+
| Version | Description    | Migrated by | Migrated at               |
+---------+----------------+-------------+---------------------------+
| * 0.2.0 |  create users  | serverbot   | 2016-09-08 10:23:54 -0500 |
| * 0.1.0 | initial schema | eprothro    | 2016-09-08 09:23:54 -0500 |
+---------+----------------+-------------+---------------------------+
```

### Data Migrations

####TODO:

Best practice is calling data massaging from the migration, implemented with nice OO elsewhere...

### Schema overrides per environment

####TODO:

Migrations define production use case. Development and/or testing use cases may have slightly different needs.

Configure keyspace and/or table properties per env that should override migrations.

Example of keyspace replication settings.

Make sure it is clear what the schema dump is (with or without overrides)

### Multiple Keyspaces

####TODO:

Don't agree with different ENVs for managing multiple keyspaces. That assumes keyspaces align with domains.

Example of counter tables in a separate keyspace for higher replication to make read pressure lower.

Manage multiple keyspaces in configruation.

Configuration defaults to simple replication with durable writes.

Example of changing replication for production and how overrides keep dev working.

### Application Growth

####TODO:

This works for starting out, single app, single dev.

This also scales well to multiple apps or microservices, and multiple teams (ops, etc.), managing and depending on a central repository of migrations with a semantically versioned database schema.

### Transitioning from Other Tools

####TODO:

Support for sucking in `cassandra_migrations` migration files and changing to semantic versioning.

```
cassie migration:import cassandra_migrate
=> 0.0.1 - cassandra_migrate/20160818213805_create_users.rb -> migrations/000_000_001_create_users.rb
=> 0.0.2 - cassandra_migrate/20160818213811_create_widgets.rb -> migrations/000_000_002_create_widgets.rb
=> 0.0.3 - cassandra_migrate/20160818213843_create_sprockets.rb -> migrations/000_000_003_create_sprockets.rb
3 migrations imported
```

Support for a .cdl migration file to act as initial migration (dump defining initial version).

```
cassie migration:initialize
=> 0.1.0 - migrations/000_001_000_initial_schema.cdl
schema initialized at v0.1.0 from current database structure
```

```
cassie migration:initialize 0.15.3
=> 0.1.0 - migrations/000_015_003_initial_schema.cdl
schema initialized at v0.15.3 from current database structure
```