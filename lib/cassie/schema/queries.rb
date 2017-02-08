module Cassie::Schema
  module Queries
    require_relative 'queries/create_schema_keyspace_query'
    require_relative 'queries/create_versions_table_query'
    require_relative 'queries/insert_version_query'
    require_relative 'queries/delete_version_query'
    require_relative 'queries/select_versions_query'
    require_relative 'queries/drop_keyspace_query'
  end
end