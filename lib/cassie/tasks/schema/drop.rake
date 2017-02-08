namespace :cassie do
  namespace :schema do
    desc "drop default keyspace and schema versioning keyspace"
    task :drop do
      include Cassie::Tasks::IO

      query = Cassie::Schema::DropKeyspaceQuery.new
      keyspaces = [Cassie.configuration[:keyspace], Cassie::Schema.schema_keyspace]

      puts "-- Dropping #{keyspaces.count} keyspaces"
      keyspaces.each do |keyspace|
        query.keyspace = keyspace
        if query.execute
          puts "  Dropped #{keyspace}"
        else
          puts red("  Failed to drop #{keyspace}")
        end
      end
      puts "done."
    end
  end
end