namespace :cassie do
  namespace :schema do
    desc "Creates the schema by executing the CQL in the schema file (`db/cassandra/schema.cql` by default)"
    task :load do
      include Cassie::Tasks::IO

      begin
        loader = Cassie::Schema::StructureLoader.new
        loader.load
        puts "[#{green("✓")}] Cassandra schema loaded from #{loader.source_path}. Schema is at #{Cassie::Schema.version}"

      rescue => e
        puts red("Error:\n#{e.message}")
      end
    end
  end
end