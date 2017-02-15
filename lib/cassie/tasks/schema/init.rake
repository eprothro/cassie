namespace :cassie do
  namespace :schema do

    desc "Initialize versioning schema and the keyspace for this environment"
    task :init => [:init_versioning, :init_keyspace]

    desc "Initialize cassie schema versioning"
    task :init_versioning do
      include Cassie::Tasks::IO

      begin
        puts "-- Initializing Cassie Versioning"
        Cassie::Schema.initialize_versioning
        puts "-- done"
      rescue Cassie::Schema::AlreadyInitiailizedError
        puts "   > Cassie Versioning already initialized "
        puts "   > Schema is at version #{Cassie::Schema.version}"
        puts "-- done"
      rescue => e
        output_error(e)
        abort
      end
    end

    desc "Initialize the keyspace for the current environment"
    task :init_keyspace do
      include Cassie::Tasks::IO

      begin
        name = Cassie.configuration[:keyspace]
        puts "-- Initializing '#{name}' Keyspace"
        query = Cassie::Schema::CreateKeyspaceQuery.new
        query.name = name
        if Cassie.configuration[:replication]
          #@todo fill in
        end

        if Cassie.keyspace_exists?(query.name)
          puts "   > '#{name}' already exists"
        else
          query.execute
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