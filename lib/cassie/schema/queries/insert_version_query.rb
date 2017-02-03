module Cassie::Schema
  class InsertVersionQuery < Cassie::Modification

    insert_into Cassie::Schema.versions_table

    set :bucket
    set :id
    set :number
    set :description
    set :executor
    set :executed_at

    map_from :version

    def bucket
      0
    end

    def keyspace
      Cassie::Schema.schema_keyspace
    end
  end
end