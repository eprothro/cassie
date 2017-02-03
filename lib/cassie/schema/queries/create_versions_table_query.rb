module Cassie::Schema
  class CreateVersionsTableQuery < Cassie::Definition
    self.prepare = false

    def statement
      %(
         CREATE TABLE #{Cassie::Schema.versions_table} (
           bucket int,
           id timeuuid,
           number text,
           description text,
           executor text,
           executed_at timestamp,
           PRIMARY KEY (bucket, id)
         ) WITH CLUSTERING ORDER BY (id DESC);
        )
    end

    def keyspace
      Cassie::Schema.schema_keyspace
    end
  end
end
