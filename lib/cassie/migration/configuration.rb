module Cassie::Migration
  # Extend a module/class with Configuration to enable migration management
  module Configuration

    attr_accessor :schema_keyspace,
                  :versions_table

    def self.extended(extender)
      extender.paths["schema_structure"] = "db/structure.cql"
      extender.schema_keyspace = "cassie_schema"
      extender.versions_table = "versions"
    end

    def paths
      @paths ||= {}.with_indifferent_access
    end
  end
end
