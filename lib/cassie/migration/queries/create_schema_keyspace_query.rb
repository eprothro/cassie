module Cassie::Migration
  class CreateSchemaKeyspaceQuery < Cassie::Definition
    self.prepare = false

    def statement
      cql = %(
        CREATE KEYSPACE #{Cassie::Migration.schema_keyspace}
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}
        AND durable_writes = true;
       )
    end

    def keyspace
      nil
    end
  end
end
