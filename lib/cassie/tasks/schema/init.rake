namespace :cassie do
  namespace :schema do

    desc "Initialize versioning schema and the keyspace for this environment"
    task :init => [:init_versioning, :init_keyspace]

    desc "Initialize cassie schema versioning"
    task :init_versioning do
      include Cassie::Tasks::IO

      begin
        Cassie::Schema.initialize_versioning
        puts "[#{green("✓")}] Versioned migrations initialized. Current version: #{Cassie::Schema.version}"
      rescue Cassie::Schema::AlreadyInitiailizedError
        puts "[#{white('╍')}] Versioned migration metatdata already exists. Current version: #{Cassie::Schema.version}"
      rescue => e
        puts e.message
        exit(1)
      end
    end

    desc "Initialize the keyspace for the current environment"
    task :init_keyspace do
      include Cassie::Tasks::IO
      Cassie.keyspace = nil
      begin
        query = Cassie::Schema::CreateKeyspaceQuery.new
        query.name = Cassie.configuration[:keyspace]
        if Cassie.configuration[:replication]
        end

        if Cassie.keyspace_exists?(query.name)
          puts "[#{white("╍")}] Keyspace '#{query.name}' already exists."
        else
          query.execute
          puts "[#{green("✓")}] Keyspace '#{query.name}' initialized."
        end

      rescue => e
        puts "Couldn't create keyspace, check #{Cassie.paths[:cluster_configurations]}:\n#{query.to_cql}"
        puts "\t"
        puts red(e.message)
        exit(1)
      end
    end
  end
end