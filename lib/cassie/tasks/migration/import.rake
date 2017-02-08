require 'optparse'
require 'cassie/schema/cassandra_migrations/importer'

namespace :cassie do
  namespace :migrations do
    desc "Imports existing `cassandra_migrations` migration files and converts to semantic versioning"
    task :import do
      include Cassie::Tasks::IO

      opts = {}
      OptionParser.new do |args|
        args.on("-p", "--path", "Directory containing existing migrations. Defaults to 'db/cassandra_migrate'.") do |p|
          opts[:path] = p
        end
      end.parse!(options)

      Cassie::Schema::CassandraMigrations::Importer.new(opts[:path]).import
    end
  end
end