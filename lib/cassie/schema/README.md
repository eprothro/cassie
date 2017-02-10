# Cassie Schema Migrations

Cassie provides versioned migrations similar to many existing adapters and frameworks.

Practically speaking, this gives your cluster Schema its own "version" and simplifies upgrading or downgrading the schema.

As such, Cassie uses semantic versioning, where a defined version describes all non-system keyspaces.

Major, minor, patch, and build versions are used, however semantic extensions are not supported (prerelase or metadata, ex: 1.0.0.beta).

### Schema Migrations
#### Creating a migration

```
cassie migration:create that_killer_feature --minor
```
```
Creating migration for schema version 0.2.0.0
  create db/cassandra/migrations/000_002_000_000_that_killer_feature.rb
```

```ruby
# db/cassandra/migrations/000_002_000_000_that_killer_feature.rb
class Migration_0_2_0_0 < Cassie::Schema::Migration
  def up
    # Uses the excellent DSL from `cassandra_migrations`.
  end

  def down
    # Uses the excellent DSL from `cassandra_migrations`.
  end
end
```

By default, the `patch` version will be bumped. Use the `--major`, `--minor`, or `--build` switch to bump differently. Or, explicitly set the version with `cassie migration:create that_fixup 0.1.3.15`.

> *Note:* The class name convention matches only the version in the filename. You can change the description suffix without having to change the classname.

#### Executing migrations

##### Roll up to latest version

```
cassie migrate
```

##### Roll up to a specific version

```
cassie migrate 0.2.0
```

##### Rolling back

Use the same interface to migrate up or down to a specific version.

```
cassie migrate 0.1.9
```

Migrating backwards rolls back the actual state of the schema in the given database. The in-database schema history keeps track of what migrations have been applied and rolls them back in that order. This is one reason for not recommending a `cassie rollback <STEP>` interface. This ensures the following scenario is supported:

* Given the following mirgations exist:
  * 0.1.0.0
  * 0.1.1.0
* And both migrations have been executed.
* When a migraiton is created for version `0.1.0.99`
* And the schema is migrated with `cassie migrate 0.1.0.0`
* Then the `down` method for `0.1.0.99` is NOT executed

* And then when the schema is migrated with `cassie migrate`, the `up` methods from the following migrations are executed:
  * 0.1.0.99
  * 0.1.1.0


#### Reporting the current version
```
cassie schema:version
+---------+----------------+-------------+---------------------------+
| Version | Description    | Migrated by | Migrated at               |
+---------+----------------+-------------+---------------------------+
| * 0.2.0 |  create users  | serverbot   | 2016-09-08 10:23:54 -0500 |
+---------+----------------+-------------+---------------------------+
```

#### Reporting the version history
```
cassie schema:history
+---------+----------------+-------------+---------------------------+
| Version | Description    | Migrated by | Migrated at               |
+---------+----------------+-------------+---------------------------+
| * 0.2.0 |  create users  | serverbot   | 2016-09-08 10:23:54 -0500 |
|   0.1.0 | initial schema | eprothro    | 2016-09-08 09:23:54 -0500 |
+---------+----------------+-------------+---------------------------+
```

#### Reporting the version status
```
cassie schema:status
+---------+----------------+-------------+---------------------------+
| Version | Description    |   Status    | Migration File            |
+---------+----------------+-------------+---------------------------+
| * 0.2.0 |  create users  | serverbot   | 2016-09-08 10:23:54 -0500 |
|   0.1.0 | initial schema | eprothro    | 2016-09-08 09:23:54 -0500 |
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

### Adding Versioning to an Existing Schema

#### Coming from `cassandra_migrations`

Support for sucking in `cassandra_migrations` migration files and changing to semantic versioning.

Import your existing `cassandra_migrations` migration files with a single task:

* Create files in `Cassie::configuration[:migrations_directory]` for each migration
  * new file prefixes are `0000_0000_0000_000i` where i increments for each migration.
* Add a versioned migration that removes `cassandra_migrations` schema from your database.
* Results in a current version of `0.0.1.0`
  * all imported versions are `0.0.0.i` where i increments for each migration.

The original `cassandra_migrations` migration files and schema in the physical layer are not changed. Remove them when comfortable.

```
cassie schema:import db/cassandra_migrate
=> 0.0.1 - cassandra_migrate/20160818213805_create_users.rb -> migrations/000_000_001_create_users.rb
=> 0.0.2 - cassandra_migrate/20160818213811_create_widgets.rb -> migrations/000_000_002_create_widgets.rb
=> 0.0.3 - cassandra_migrate/20160818213843_create_sprockets.rb -> migrations/000_000_003_create_sprockets.rb
3 migrations imported
```

#### Coming from no explicit migration/versioning management

Import your existing schema held in Cassandra with a single task:

* Dump your current schema into `db/cassandra/cassandra.cdl`
* Copy the current schema into an initial `up` migration.
* Result in a current version of `0.1.0`

```
cassie schema:import
=> 0.1.0 - migrations/000_001_000_initial_schema.cdl
schema now at v0.1.0
```
Set the version if something other than 0.1.0 is desired.

```
cassie schema:import 0.15.3
=> 0.15.3 - migrations/000_015_003_initial_schema.cdl
schema now at v0.15.3
```

### Architecture

#### Versions

A `Version` is a container class for a `migration`. A version may be applied in the current database's schema, or not.

There are multiple independent, but potentially related/overlapping collections of `versions`.

One is `Cassie::Schema.applied_versions`, which is the set of versions that have been applied, in the past, to a Cassandra database.

Another is `Cassie::Schema.local_versions`, which the set of versions represented by migration files found in the `migrations_directory`.

Versions are migrated up or down, and then recorded or forgotten, respectively, in the database's configurable `<schema_keyspace>.<versions_table>` (`cassie_schema.versions` by default).

#### Migrations

Strictly speaking, the *version* is what is being migrated up or down. The `Migration` is the class defining code to execute `up` or `down`. The version object delegates implementation of the migration to the `Migration` object.

This class embeds the version number in it, but the `Migration` object does not know about the concept of its version. A migration file is used to load a `Version`, which contains the `Migration` object.

Cassie only expects that the version number emedded in the class name match the one embedded in the file name.

This means you can change the description embedded in the migration file without having to rename the class.