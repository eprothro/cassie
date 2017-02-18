module Cassie::Schema
  class SelectVersionsQuery < Cassie::Query

    select_from Cassie::Schema.versions_table

    where :application, :eq
    where :env, :eq

    def env
      Cassie.env
    end

    def application
      Cassie::Schema.application
    end

    def build_result(row)
      Version.new(row["number"],
                  row["description"],
                  row["id"],
                  row["executor"],
                  row["executed_at"])
    end

    def keyspace
      Cassie::Schema.schema_keyspace
    end
  end
end