module Test
  class KeyspaceDropper < Cassie::Definition

    keyspace nil

    def statement
      %(
        DROP KEYSPACE IF EXISTS #{keyspace_name};
       )
    end

    def keyspace_name
      Cassie.configuration['keyspace']
    end
  end
end