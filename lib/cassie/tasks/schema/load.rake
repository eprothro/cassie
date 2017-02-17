namespace :cassie do
  namespace :schema do
    desc "Creates the schema by executing the schema file (`db/cassandra/schema.rb` by default)"
    task :load do
      include Cassie::Tasks::IO

      begin
        loader = Cassie::Schema::SchemaLoader.new
        puts "-- Loading '#{Cassie.env}' Schema from #{loader.source_path}"
        loader.load
        puts "   > '#{Cassie.env}' schema is now at version #{Cassie::Schema.version}"
        puts "-- done"
      rescue => e
        output_error(e)
        abort
      end
    end
  end
end