namespace :cassie do
  namespace :schema do
    desc "Creates the schema by executing the CQL in the schema file (`db/cassandra/schema.cql` by default)"
    task :load do
      include Cassie::Tasks::IO

      begin
        loader = Cassie::Schema::StructureLoader.new
        puts "-- Loading Schema from #{loader.source_path}"
        loader.load
        puts "   > Schema is now at version #{Cassie::Schema.version}"
        puts "-- done"
      rescue => e
        output_error(e)
        abort
      end
    end
  end
end