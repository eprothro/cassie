## 1.0.0.beta.20

Added:
  - add select logic with `select` method and helpers (`writetime`, `count`, etc)
  - separate query results into separate enumerable object decorating Cassandra::Results object
  - separate `Cassandra::Query` classes `Cassandra::Modification` (see Readmes)

Changed:
  - breaking: rename `build_resource` to `build_result`
  - breaking: rename `select` to `select_from`
  - deprecate `insert` in favor of `insert_into`
  - deprecate `delete` in favor of `delete_from`

Removed:
  - insert alias for execute
  - update alias for execute
  - delete alias for execute
  - select alias for execute