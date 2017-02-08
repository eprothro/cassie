namespace :cassie do
  namespace :structure do
    desc "Creates the schema by executing the CQL schema in the structure file (`db/cassandra/structure.cql` by default)"
    task :load do
      include Cassie::Tasks::IO

      begin
        loader = Cassie::Schema::StructureLoader.new
        loader.load
        puts "[#{green("✓")}] Cassandra schema loaded from #{loader.source_path}"

      rescue => e
        puts e.message
        exit(1)
      end
    end
  end
end