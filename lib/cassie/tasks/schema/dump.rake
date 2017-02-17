namespace :cassie do
  namespace :schema do
    desc "Dumps the schema for configured keyspace into schema file (`db/cassandra/schema.rb` by default)"
    task :dump do
      include Cassie::Tasks::IO

      begin
        puts "-- Dumping Cassandra schema (version #{Cassie::Schema.version})"
        dumper = Cassie::Schema::SchemaDumper.new
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