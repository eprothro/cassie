namespace :cassie do
  namespace :schema do
    desc "Create an initial migration based on the current Cassandra non-system schema"
    task :import do
      include Cassie::Tasks::IO

      importer = Cassie::Schema::Migration::CassandraImporter.new(keyspace)

      importer.import
    end
  end
end
