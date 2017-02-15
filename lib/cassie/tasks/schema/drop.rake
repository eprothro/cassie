namespace :cassie do
  namespace :schema do
    desc "drop default keyspace and schema versioning keyspace"
    task :drop do
      include Cassie::Tasks::IO
      begin
        query = Cassie::Schema::DropKeyspaceQuery.new
        keyspaces = [Cassie.configuration[:keyspace]]

        puts "-- Dropping schema for #{Cassie::Schema.application}[#{Cassie.env}]"
        keyspaces.each do |keyspace|
          query.keyspace = keyspace
          puts "   - Dropping '#{keyspace}'"
          if Cassie.keyspace_exists?(keyspace)
            query.execute!
          else
            puts "     > '#{keyspace}' does not exist"
          end
          puts "   - done"
        end
        puts "   - Clearning schema version metadata"
          count = Cassie::Schema.applied_versions.count
          Cassie::Schema::DeleteVersionQuery.new.execute!
          puts "     > removed #{count} #{'version'.pluralize(count)}"
        puts "   - done"
        puts "-- done"
      rescue => e
        output_error(e)
        abort
      end
    end
  end
end