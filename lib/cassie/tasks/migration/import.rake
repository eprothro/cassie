require 'optparse'
require 'cassie/schema/cassandra_migrations/importer'

namespace :cassie do
  namespace :migrations do
    desc "Imports existing `cassandra_migrations` migration files and converts to semantic versioning"
    task :import do
      include Cassie::Tasks::IO

      begin
        puts "-- Importing `cassandra_migrations` migration files"
        opts = {}
        OptionParser.new do |args|
          args.on("-p", "--path", "Directory containing existing migrations. Defaults to 'db/cassandra_migrate'.") do |p|
            opts[:path] = p
          end
        end.parse!(options)

        importer = Cassie::Schema::CassandraMigrations::Importer.new(opts[:path])
        importer.before_each = Proc.new do |migration_file|
          rel_path = migration_file.filename.sub(Dir.pwd, "")
          puts "   - Importing #{rel_path}"
        end
        importer.after_each = Proc.new do |version|
          rel_path = version.migration.path.sub(Dir.pwd, "")
          puts "     > #{green('created')} #{rel_path}"
          puts "     > #{white('recorded')} version #{version}"
          puts "   - done"
        end

        importer.import
        puts "-- done"
      rescue => e
        puts red("Error:\n  #{e.message}")
        abort
      end
    end
  end
end