namespace :cassie do
  namespace :schema do

    desc "Initialize the keyspace for the current environment"
    task :init_keyspace do
      include Cassie::Tasks::IO

      begin
        name = Cassie.configuration[:keyspace]
        puts "-- Initializing '#{name}' Keyspace"

        query = Cassie::Schema::CreateKeyspaceQuery.new
        query.name = name
        if replication = Cassie.configuration[:replication]
          query.replication_class = replication[:class] if replication.has_key?(:class)
          query.replication_factor = replication[:replication_factor] if replication.has_key?(:replication_factor)
        end
        query.durable_writes = Cassie.configuration[:durable_writes] if Cassie.configuration.has_key?(:durable_writes)

        if Cassie.keyspace_exists?(query.name)
          puts "   > '#{name}' already exists"
        else
          query.execute!
        end
        puts "-- done"

      rescue => e
        puts red("Couldn't create keyspace, check #{Cassie.paths[:cluster_configurations]}:\n#{query.to_cql}")
        puts "\t"
        output_error(e)
        abort
      end
    end
  end
end