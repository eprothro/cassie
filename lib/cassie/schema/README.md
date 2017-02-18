# Cassie Schema Migrations

Cassie provides versioned migrations similar to many existing adapters and frameworks.

Practically speaking, this gives your cluster Schema its own "version" and simplifies upgrading or rolling back the schema.

As such, Cassie uses semantic versioning, where a defined version describes the keyspace defined in the cluster configuration.

Major, minor, patch, and build versions are used, however semantic extensions are not recommended (prerelase or metadata, eg: 1.0.0.beta).

### Schema Migrations

Schema version and migrations are managed through various `cassie` tasks. See below for basic usage.

List command descriptions and advanced options:
```
cassie --help
```

If using Rails, and Rails needs to be initialized when loading `cassandra.yml` or your migration files, remember to use the `cassie-rails` commands.

#### Getting Started

If no schema has been defined yet (e.g. no keyspace, tables, or types), simply initialize Cassie versioning:

```
cassie schema:init
```

```
-- Initializing Cassie Versioning
-- done
-- Initializing 'my_app_development' Keyspace
-- done
```

If an existing schema (e.g. keyspace, tables, types) is alredy defined, see below on how to import it.

#### Importing an existing schema

##### Coming from `cassandra_migrations`

Import your existing `cassandra_migrations` migration files with a single task:

```
cassie migrations:import
```
```bash
-- Initializing Cassie Versioning
-- done
-- Initializing 'cassie_development' Keyspace
-- done
-- Importing `cassandra_migrations` migration files
   - Importing db/cassandra_migrate/20161206214301_initial_database.rb
     > created /db/cassandra/migrations/0000_0000_0000_0001_initial_database.rb
     > recorded version 0.0.0.1
   - done
   - Importing db/cassandra_migrate/20161212210447_add_username_to_users.rb
     > created /db/cassandra/migrations/0000_0000_0001_0000_add_username_to_users.rb
     > recorded version 0.0.1.0
   - done
   - Importing db/cassandra_migrate/20161213163201_add_reserved_to_users.rb
     > created /db/cassandra/migrations/0000_0000_0002_0000_add_reserved_to_users.rb
     > recorded version 0.0.2.0
   - done
-- done
-- Dumping Cassandra schema (version 0.0.0.1)
   - Writing to db/cassandra/schema.rb
   - done
-- done
```

> The original `cassandra_migrations` migration files and schema in the physical layer are not changed. Remove the old files when comfortable.

##### Coming from no explicit migration/versioning management

Import your existing schema held in Cassandra with a single task:

```
cassie schema:import
```

```
-- Initializing Cassie Versioning
-- done
-- Initializing 'my_app_development' Keyspace
   > 'my_app_development' already exists
-- done
-- Importing Schema from Cassandra
   - Creating initial version
     > created db/cassandra/migrations/0000_0000_0001_0000_import_my_app_development.rb
     > recorded version 0.0.1.0
   - done
-- done
-- Dumping Cassandra schema (version 0.0.1.0)
   - Writing to db/cassandra/schema.rb
   - done
-- done
```

##### Initializing versioning

Locally, these import tasks will also initialiaze the local version tracking to have all migration versions recorded.

However, another developer's or environment's database does not have this schema metadata. Syncronize version tracking by initializing cassie schema with the version of the current in-database schema.

```
cassie schema:init -v 0.0.2.0
```

```
-- Initializing Cassie Versioning
-- done
-- Fast-forwarding to version 0.0.2.0
   > Recorded version 0.0.0.1
   > Recorded version 0.0.1.0
   > Recorded version 0.0.2.0
-- done
-- Initializing 'cassie_development' Keyspace
-- done
```

This does not run any migrations, but rather updates schema version metadata, so future migrations begin after the provided version.

#### Creating a migration

```
cassie migration:create that killer feature
```

```
-- Creating migration file for version 0.0.1.0
   > created db/cassandra/migrations/0000_0000_0001_0000_that_killer_feature.rb
-- done
```

```ruby
# db/cassandra/migrations/0000_0000_0001_0000_that_killer_feature.rb
class Migration_0_0_1_0 < Cassie::Schema::Migration
  def up
    # Code to execute when applying this migration
    # Supports the excellent `cassandra_migrations` DSL
    # or call `execute` to call `Cassandra::Session.execute`
  end

  def down
    # Code to execute when rolling back this migration
    # Supports the excellent `cassandra_migrations` DSL
    # or call `execute` to call `Cassandra::Session.execute`
  end
end

```

By default, the `patch` version will be bumped. Use the `--major` (`-M`), `--minor` (`-m`), or `--build` (`-b`) switches to bump differently. Or, explicitly set the version with `--version` (`-v`): `cassie migration:create that fixup -v 0.1.3.15`.

> *Note:* The class name only needs to match the version in the filename. The description suffix can be changed without having to change the classname.

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

#### Reporting the current version
```
cassie schema:version
```
```
+-----------+----------------+-------------+---------------------------+
|                      Environment: development                        |
+-----------+----------------+-------------+---------------------------+
|  Version  | Description    | Migrated by | Migrated at               |
+-----------+----------------+-------------+---------------------------+
| * 0.2.0.0 |  create users  | serverbot   | 2016-09-08 10:23:54 -0500 |
+-----------+----------------+-------------+---------------------------+
```

#### Reporting the version history
```
cassie schema:history
```
```
+-----------+----------------+-------------+---------------------------+
|                      Environment: development                        |
+-----------+----------------+-------------+---------------------------+
|  Version  | Description    | Migrated by | Migrated at               |
+-----------+----------------+-------------+---------------------------+
| * 0.2.0.0 |  create users  | serverbot   | 2016-09-08 10:23:54 -0500 |
|   0.1.0.0 | initial schema | eprothro    | 2016-09-08 09:23:54 -0500 |
+-----------+----------------+-------------+---------------------------+
```

#### Reporting the version status

Display all applied and unapplied migrations.

```
cassie schema:status
```
```
+-----------+----------------+--------+---------------------------------------------------------------+
|                                      Environment: development                                       |
+-----------+----------------+--------+---------------------------------------------------------------+
| Number    | Description    | Status | Migration File                                                |
+-----------+----------------+--------+---------------------------------------------------------------+
|   0.0.3.0 | create friends |  DOWN  | db/cassandra/migrations/0000_0000_0003_0000_create_friends.rb |
| * 0.0.2.0 | create users   |   UP   | db/cassandra/migrations/0000_0000_0002_0000_create_users.rb   |
|   0.1.0.0 | initial schema |   UP   | db/cassandra/migrations/0000_0000_0001_0000_initial_schema.rb |
+-----------+----------------+--------+---------------------------------------------------------------+
```

### Schema Management

The full schema is stored in `schema.rb`, this is recommended to be checked into source control.
It is updated (with a full dump) after each migration, to maintain a truth-store for the schema when used with multiple developers.

#### Dump the schema

```
cassie schema:dump
```
```
-- Dumping Cassandra schema (version 0.2.0.0)
   - Writing to db/cassandra/schema.rb
   - done
-- done
```

#### Drop the schema
```
cassie schema:drop
```
```
-- Dropping 2 keyspaces
   - Dropping 'my_app_development'
   - done
   - Dropping 'cassie_schema'
   - done
-- done
```

#### Load the schema
```
cassie schema:load
```
```
-- Loading Schema from db/cassandra/schema.rb
   > Schema is now at version 0.2.0.0
-- done
```

#### Reset the schema

```
cassie schema:reset
```
```
-- Dropping 2 keyspaces
   - Dropping 'my_app_development'
   - done
   - Dropping 'cassie_schema'
   - done
-- done
-- Loading Schema from db/cassandra/schema.rb
   > Schema is now at version 0.2.0.0
-- done
```

#### Reset the schema and migrate

This task reload the schema from the schema file, and then proceeds with incremental migrations up to the latest migration.

```
cassie migrate:reset
```
```
-- Dropping 2 keyspaces
   - Dropping 'cassie_development'
   - done
   - Dropping 'cassie_schema'
   - done
-- done
-- Loading Schema from db/cassandra/schema.rb
   > Schema is now at version 0.2.0.0
-- done
-- Migrating to version 0.2.1.0
   - Migragting version 0.2.1.0 UP
   - done (4.89 ms)
-- done
-- Dumping Cassandra schema (version 0.2.1.0)
   - Writing to db/cassandra/schema.rb
   - done
-- done
```

### Managing Envrionments

Set the environment with `RACK_ENV`, `CASSANDRA_ENV` or the `--env`(`-e`) switch for `cassie` commands:

```
RACK_ENV=test cassie migrate:reset
```
is equivalent to
```
cassie migrate:reset -e test
```

The `schema.rb` file contains keyspace-agnostic DSL. When loading the schema, its commands will be run against the default keyspace for the environment.


### Version / Migration Architecture (`cassie` developers)

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

#### A Note on rollback

Migrating down rolls back the state of the schema in the Cassandra database. The in-database schema history keeps track of what migrations have been applied and rolls them back in that order (as opposed to whatever order the files indicate). This ensures the following scenario is supported:

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