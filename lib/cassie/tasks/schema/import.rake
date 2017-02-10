namespace :cassie do
  namespace :schema do
    desc "Create an initial schema version based on the current schema"
    task :import => :init do
      include Cassie::Tasks::IO

      begin
        version = Cassie::Schema.next_version
        keyspace = Cassie.configuration[:keyspace]

        puts "-- Importing Schema from Cassandra"

        version.description = "import #{keyspace}"
        dumper = Cassie::Schema::StructureDumper.new
        writer = Cassie::Schema::VersionWriter.new(version)
        contents = dumper.keyspace_structure.gsub(/\n\n/, "")
        contents = contents.gsub(/(\A\n|\n\z)/, "")
        writer.up_code = "cql = <<-EOS\n#{contents}\nEOS\n"
        writer.up_code += "    execute(cql)"
        writer.down_code = "execute('DROP KEYSPACE #{Cassie.configuration[:keyspace]};')"

        puts "   - Creating initial version"
        rel_path = writer.filename.sub(Dir.pwd, "")
        writer.write
        puts "     > #{green("created")} #{rel_path}"
        Cassie::Schema.record_version(version)
        puts "     > #{white('recorded')} version #{version}"
        puts "   - done"
        puts "-- done"
      rescue => e
        puts red("Error:\n  #{e.message}")
        abort
      end
    end
  end
end

Rake::Task["cassie:schema:import"].enhance do
  Rake::Task["cassie:schema:dump"].invoke
end