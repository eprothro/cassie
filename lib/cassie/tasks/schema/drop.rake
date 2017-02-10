namespace :cassie do
  namespace :schema do
    desc "drop default keyspace and schema versioning keyspace"
    task :drop do
      include Cassie::Tasks::IO
      begin
        query = Cassie::Schema::DropKeyspaceQuery.new
        keyspaces = [Cassie.configuration[:keyspace], Cassie::Schema.schema_keyspace]

        puts "-- Dropping #{keyspaces.count} keyspaces"
        keyspaces.each do |keyspace|
          query.keyspace = keyspace
          if Cassie.keyspace_exists?(keyspace)
            query.execute
            puts "  Dropped '#{keyspace}'"
          else
            puts "  '#{keyspace}' does not exist, proceeding..."
          end


        end
        puts "done."
      rescue => e
        puts red("Error:\n#{e.message}")
      end
    end
  end
end