require 'pathname'

module Cassie::Schema
  # Extend a module/class with Configuration to enable migration management
  module Configuration

    # The keyspace in which to store Cassie schema data
    attr_accessor :schema_keyspace
    # The table in which to store Cassie schema applied versions data
    attr_accessor :versions_table

    # @!visibility private
    def self.extended(extender)
      extender.paths[:schema_file] = "db/cassandra/schema.rb"
      extender.paths[:migrations_directory] = "db/cassandra/migrations"
      extender.schema_keyspace = "cassie_schema"
      extender.versions_table = "versions"
    end

    # Paths used for configuration loading.
    #
    # @return [Hash]
    #   * +:schema_file+ - The .rb file defining the current schema structure
    #   * +:migrations_directory+ - The directory containing the versioned schema migration .rb files
    def paths
      @paths ||= {}.with_indifferent_access
    end

    protected

    def root
      Pathname.new(Dir.pwd)
    end
  end
end
