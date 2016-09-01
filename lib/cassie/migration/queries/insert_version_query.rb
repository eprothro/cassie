module Cassie::Migration
  class InsertVersionQuery < Cassie::Modification

    insert_into Cassie::Migration.versions_table

    set :bucket
    set :id
    set :version_number
    set :description
    set :migrator
    set :migrated_at

    map_from :version

    def bucket
      0
    end

    def keyspace
      Cassie::Migration.schema_keyspace
    end
  end
end