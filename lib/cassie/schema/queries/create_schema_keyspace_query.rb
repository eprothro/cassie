module Cassie::Schema
  class CreateSchemaKeyspaceQuery < Cassie::Definition
    self.prepare = false

    def statement
      cql = %(
        CREATE KEYSPACE #{Cassie::Schema.schema_keyspace}
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}
        AND durable_writes = true;
       )
    end

    def keyspace
      nil
    end
  end
end
