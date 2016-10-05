module Test
  class KeyspaceCreator < Cassie::Definition

    keyspace nil

    def statement
      %(
        CREATE KEYSPACE IF NOT EXISTS #{keyspace_name}
        WITH replication = {'class': 'SimpleStrategy',
                            'replication_factor': '1'}
        AND durable_writes = true;
       )
    end

    def keyspace_name
      Cassie.configuration['keyspace']
    end
  end
end