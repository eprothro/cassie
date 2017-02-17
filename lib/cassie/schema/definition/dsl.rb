module Cassie::Schema
  module Definition

    # DSL for Cassie::Schema Defintion
    # these methods can be called in a schema.rb
    # file to define keyspace agnostic schema.
    # When executed, they will then create that schema
    # for the currently defined default keyspace found
    # in +Cassie.configuration[:keyspace]+.
    class DSL
      class << self

        # The default keyspace according to the
        # cluster configuration in +Cassie.configuration[:keyspace]+
        # @return [String] the keyspace name
        def default_keyspace
          Cassie.configuration[:keyspace]
        end

        # Execute the given CQL on the current cluster, using an
        # unscoped session. CQL should be keyspace agnostic, where
        # keyspace names are interpolated with the +#{default_keyspace}+.
        # Table names must be fully qualified.
        # @return [Cassandra::Result] the result of execution
        def create_schema(cql)
          cql.strip.split(";").each do |statement|
            Cassie.session(nil).execute("#{statement.strip};")
          end
        end

        def record_version(number, description, uuid, executor, executed_at_utc)
          id = Cassandra::TimeUuid.new(uuid)
          executed_at = DateTime.parse(executed_at_utc) rescue nil
          version = Version.new(number, description, id, executor, executed_at)

          Cassie::Schema.initialize_versioning

          Cassie::Schema.record_version(version)
        end
      end
    end
  end
end