module Cassie::Schema
  class CreateVersionsTableQuery < Cassie::Definition
    self.prepare = false

    def statement
      %(
         CREATE TABLE IF NOT EXISTS #{Cassie::Schema.versions_table} (
           application text,
           env text,
           id timeuuid,
           number text,
           description text,
           executor text,
           executed_at timestamp,
           PRIMARY KEY ((application, env), id)
         ) WITH CLUSTERING ORDER BY (id DESC);
        )
    end

    def keyspace
      Cassie::Schema.schema_keyspace
    end
  end
end
