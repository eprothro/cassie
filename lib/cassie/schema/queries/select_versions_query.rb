module Cassie::Schema
  class SelectVersionsQuery < Cassie::Query

    select_from Cassie::Schema.versions_table

    def build_result(row)
      Version.new(row["number"],
                  row["description"],
                  row["id"],
                  row["migrator"],
                  row["migrated_at"])
    end

    def keyspace
      Cassie::Schema.schema_keyspace
    end
  end
end