module Cassie::Schema
  class DeleteVersionQuery < Cassie::Modification

    delete_from Cassie::Schema.versions_table

    where :id, :eq
    where :bucket, :eq

    def bucket
      0
    end

    def keyspace
      Cassie::Schema.schema_keyspace
    end
  end
end