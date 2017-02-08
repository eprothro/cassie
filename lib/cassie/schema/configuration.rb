require 'pathname'

module Cassie::Schema
  # Extend a module/class with Configuration to enable migration management
  module Configuration

    attr_accessor :schema_keyspace,
                  :versions_table

    # @!visibility private
    def self.extended(extender)
      extender.paths["schema_structure"] = "db/cassandra/structure.cql"
      extender.paths["migrations_directory"] = "db/cassandra/migrations"
      extender.schema_keyspace = "cassie_schema"
      extender.versions_table = "versions"
    end

    def paths
      @paths ||= {}.with_indifferent_access
    end

    def root
      Pathname.new(Dir.pwd)
    end
  end
end
