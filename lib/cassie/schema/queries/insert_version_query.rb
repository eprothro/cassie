module Cassie::Schema
  class InsertVersionQuery < Cassie::Modification
    # use fully-qualified tablename
    # for cql generation for standalone queries
    self.keyspace = nil

    insert_into "#{Cassie::Schema.schema_keyspace}.#{Cassie::Schema.versions_table}"

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
  end
end