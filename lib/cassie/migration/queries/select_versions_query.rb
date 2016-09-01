module Cassie::Migration
  class SelectVersionsQuery < Cassie::Query

    select Cassie::Migration.versions_table

    def build_resource(row)
      Version.new(*row.values_at(*Version.members.map(&:to_s)))
    end

    def keyspace
      Cassie::Migration.schema_keyspace
    end
  end
end