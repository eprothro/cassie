## 1.0.0.beta.21

Added:
  - select support with `select` method and helpers (`writetime`, `count`, etc)
  - dynamic term support and non-positional terms (`now()`, `minTimeUuid(?)`, etc)
  - separate `Cassandra::Query`, `Cassandra::Definition`, and `Cassandra::Modification` base classes (see Readmes)
  - `cassie tail` command
  - `cassie stop``--all` switch
  - support for synthetic partition linking (see Readmes)
  - `Cassie::Statements.default_limit`

Changed:
  - breaking: rename `build_resource` to `build_result`
  - breaking: rename `select` to `select_from`
  - breaking: moved `next_row` out of query and into `result`, now named `peeked_row`
  - breaking: moved `next_max_cursor` and `next_max_<identifier>` out of query object and into `result` object
  - deprecate `insert` in favor of `insert_into`
  - deprecate `delete` in favor of `delete_from`
  - query results are now an enumerable object decorating Cassandra::Results object, accessable via `result` after execution, or directly via `fetch`
  - `value` options for `set` and `where` DSL now only accepts a symbol for a method to call. (no longer supports string eval or static values)

Removed:
  - `insert` alias for execute
  - `update` alias for execute
  - `delete` alias for execute
  - `select` alias for execute
  - `Cassie::Statements::Statement::Pagination::PageSize.default`, use `Cassie::Statements.default_limit` instead.