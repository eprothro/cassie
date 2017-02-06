require 'optparse'
require_relative '../../schema/cassandra_migrations/importer'

namespace :cassie do
  namespace :migrations do
    desc "Imports existing `cassandra_migrations` migration files and converts to semantic versioning"
    task :import do
      opts = {}
      OptionParser.new do |args|
        args.on("-p", "--path", "Directory containing existing migrations. Defaults to 'db/cassandra_migrate'.") do |p|
          opts[:path] = p
        end
      end.parse!
      importer = Cassie::Schema::CassandraMigrations::Importer.new(path)

      importer.import
    end
  end
end