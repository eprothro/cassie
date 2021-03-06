# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 1.1.5

### Fixed
- A bug where Cassie::Testing::Fake::Result#empty? returned the incorrect value

## 1.1.4

### Changed
- Cassie::Statements::Execution#execute now accepts an optional hash of cassandra_driver execution options

### Fixed
- Tasks that drop, now have a 10 second timeout. Fixes [Issue 26](https://github.com/eprothro/cassie/issues/26)

## 1.1.2

### Fixed
- Bug where executing `schema:migrate` immediately after `schema:init -v SOME_VERSION` recorded incorrectly ordered version history.

## 1.1.1

### Fixed
- Bug where `replication` settings from legacy cassandra_migrations style config file weren't honored and caused failed `schema:init` task.

### Changed
- Optimization: use cluster metadata instead of queries to see if schema table exists when loading schema.rb

## 1.1.0

### Changed
- Schema versioning now supports multiple envrionments more robustly. Drop your `cassie_schema.versions` table and run `cassie schema:init -v <last schema version applied>` to upgrade.
- `schema.cql` is replaced by keyspace-agnostic `schema.rb` with robust support for multiple environments. Paves the way to multiple-keyspace support as well. `schema.cql` is deprecated.
- `Cassie::Schema::StructureDumper` and `Cassie::Schema::StructureLoader` are deprecated in favor of `Cassie::Schema::SchemaDumper` and `Cassie::Schema::SchemaLoader`

## 1.0.6 (prerelease)
### Added
- `--trace` option to `cassie` commands to show error backtraces
- `--version` option to `cassie schema:init` to fast-forward to a version that matches an existing schema

### Fixed
- bug where `cassie start` didn't show the readable error if cassandra was already

### Changed
- TaskRunner.new accepts `args`
- Replaced TaskRunner.run_command(args) with `run`

## 1.0.5
### Fixed
- bug where `Cassie::Schema.record_version` failed for new migrations

## 1.0.4
### Changed
- `cassie migrations:import` now dumps the schema after succeeding

### Fixed
- bug where `cassie:migrations:import` didn't initialize schema
- bug where `Cassie::Schema.record_version` silently failed

## 1.0.3

### Fixed
- bug where `cassie` commands that accept value-based switches (--path path/to/foo.rb) didn't accept values correctly

## 1.0.2

### Fixed
- argv support for sinatra/rails applications using .rake tasks

## 1.0.0

### Added
- Full support for versioned schema migrations. See the [Migrations README](./lib/cassie/schema/README.md#readme) for more on features and usage.
- Support for importing legacy `cassandra_migrations` migrations. See the [Migrations README](./lib/cassie/schema/README.md#readme).
- Various `cassie` tasks, see [README](./README.md).
- Inline documentation

### Changed
- `Cassie::Support::SystemCommand` is now `Cassie::Support::SystemCommand`
- `Cassie::Support::SystemCommand#run!` is now `Cassie::Support::SystemCommand.succeed`

### Removed
- deleted the depreated `Query.insert`. Use `Query.insert_into`.
- deleted the depreated `Query.delete`. Use `Query.delete_from`.

## 1.0.0.beta.33

### Added
- Support for `allow_filtering` to Selection Statements

## 1.0.0.beta.32

### Added
- Support for rails 5

## 1.0.0.beta.31

### Added
- Statement support for deleting specific columns

### Fixed
- Bug where instrumentation didn't report keyspace correctly on cassie.session.connect

## 1.0.0.beta.30

### Changed
- Cluser and session connection logging outputs hash now to support complex formatting (JSON,etc)

## 1.0.0.beta.29

### Fixed
- bug where insert queries didn't respect `if` options

## 1.0.0.beta.28

### Fixed
- bug where values weren't lazily evaluated for Assignements (`set`)

## 1.0.0.beta.27

### Added
- `non_idempotent` helper

### Changed
- `Cassie::Statements.default_idempotency` now defaults to `true`

## 1.0.0.beta.26

### Fixed
- Bug where nil values for arguments and relations didn't result in the correct number of bindings

## 1.0.0.beta.25

### Added
- `Cassie::Support::SystemCommand#run!`
- support for statement idempotency and type hinting (Selections default to idempotent)
- Cassie::Statement `execute!` helper that raises if execution fails

### Fixed
- Bug where nil values for arguments didn't result in the correct number of bindings


## 1.0.0.beta.24

### Added
- `Cassie::Result::QueryResult.first!`
- `to_cql` method to Statements, providing CQL strings that are executable in `cqlsh`

## 1.0.0.beta.22

### Added
- `Cassie::Statements.default_consistency`, fallback for query classes

## 1.0.0.beta.21

### Added
- select support with `select` method and helpers (`writetime`, `count`, etc)
- dynamic term support and non-positional terms (`now()`, `minTimeUuid(?)`, etc)
- separate `Cassandra::Query`, `Cassandra::Definition`, and `Cassandra::Modification` base classes (see Readmes)
- `cassie tail` command
- `cassie stop``--all` switch
- support for synthetic partition linking (see Readmes)
- `Cassie::Statements.default_limit`

### Changed
- breaking: rename `build_resource` to `build_result`
- breaking: rename `select` to `select_from`
- breaking: moved `next_row` out of query and into `result`, now named `peeked_row`
- breaking: moved `next_max_cursor` and `next_max_<identifier>` out of query object and into `result` object
- deprecate `insert` in favor of `insert_into`
- deprecate `delete` in favor of `delete_from`
- query results are now an enumerable object decorating Cassandra::Results object, accessable via `result` after execution, or directly via `fetch`
- `value` options for `set` and `where` DSL now only accepts a symbol for a method to call. (no longer supports string eval or static values)

### Removed
- `insert` alias for execute
- `update` alias for execute
- `delete` alias for execute
- `select` alias for execute
- `Cassie::Statements::Statement::Pagination::PageSize.default`, use `Cassie::Statements.default_limit` instead.