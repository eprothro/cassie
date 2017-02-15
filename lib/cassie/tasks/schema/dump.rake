namespace :cassie do
  namespace :schema do
    desc "Dumps the schema for all non-system keyspaces in CQL format (`db/cassandra/schema.cql` by default)"
    task :dump do
      include Cassie::Tasks::IO

      begin
        puts "-- Dumping Cassandra schema (version #{Cassie::Schema.version})"
        dumper = Cassie::Schema::StructureDumper.new
        puts "   - Writing to #{dumper.destination_path}"
        dumper.dump
        puts "   - done"
        puts "-- done"

      rescue => e
        output_error(e)
        abort
      end
    end
  end
end