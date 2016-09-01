module Cassie::Migration
  class CreateVersionsTableQuery < Cassie::Query
    self.prepare = false

    def statement
      %(
         CREATE TABLE #{Cassie::Migration.versions_table} (
           bucket int,
           id timeuuid,
           version_number text,
           description text,
           migrator text,
           migrated_at timestamp,
           PRIMARY KEY (bucket, id)
         ) WITH CLUSTERING ORDER BY (id DESC);
        )
    end

    def keyspace
      Cassie::Migration.schema_keyspace
    end
  end
end
