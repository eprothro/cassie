namespace :cassie do
  namespace :schema do
    desc "Create an initial schema version based on the current schema"
    task :import => :init do
      include Cassie::Tasks::IO

      version = Cassie::Schema.next_local_version
      version.description = "Import #{Cassie.configuration[:keyspace]}"
      version.prepare_for_execution
      dumper = Cassie::Schema::StructureDumper.new

      writer = Cassie::Schema::VersionWriter.new(version)
      contents = dumper.keyspace_structure.gsub(/\n\n/, "")
      contents = contents.gsub(/(\A\n|\n\z)/, "")
      writer.up_code = "cql = <<-EOS\n#{contents}\nEOS\n"
      writer.up_code += "    execute(cql)"
      writer.down_code = "execute('DROP KEYSPACE #{Cassie.configuration[:keyspace]};')"
      writer.write

      rel_path = writer.filename.sub(Dir.pwd, "")
      puts green("  create #{rel_path}")

      Cassie::Schema.record_version(version)
    end
  end
end

Rake::Task["cassie:schema:import"].enhance do
  Rake::Task["cassie:schema:dump"].invoke
end