namespace :cassie do
  namespace :structure do
    desc "Dumps the schema for all non-system keyspaces in CQL format (`db/cassandra/structure.cql` by default)"
    task :dump do
      begin
        dumper = Cassie::Schema::StructureDumper.new
        dumper.dump
        puts "[#{green("✓")}] Cassandra schema written to #{dumper.destination_path}"

      rescue => e
        puts e.message
        exit(1)
      end
    end
  end
end