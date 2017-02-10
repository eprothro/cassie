namespace :cassie do
  namespace :schema do
    desc "Dumps the schema for all non-system keyspaces in CQL format (`db/cassandra/schema.cql` by default)"
    task :dump do
      include Cassie::Tasks::IO

      begin
        dumper = Cassie::Schema::StructureDumper.new
        dumper.dump
        puts "[#{green("✓")}] Cassandra schema (version #{Cassie::Schema.version}) written to #{dumper.destination_path}"

      rescue => e
        puts red("Error:\n#{e.message}")
      end
    end
  end
end