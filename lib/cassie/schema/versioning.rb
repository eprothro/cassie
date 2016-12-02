require 'etc'

module Cassie::Schema
  require_relative 'version'

  class AlreadyInitiailizedError < StandardError; end
  class UninitializedError < StandardError; end

  module Versioning
    def version_number
      return nil unless version
      version.number
    end

    def version
      SelectVersionsQuery.new.fetch_first || Version.new('0')
    rescue Cassandra::Errors::InvalidError
      raise uninitialized_error
    end

    def versions
      SelectVersionsQuery.new.fetch
    rescue Cassandra::Errors::InvalidError
      raise uninitialized_error
    end

    def initialize_versioning
      create_schema_keyspace unless keyspace_exists?
      raise Cassie::Schema::AlreadyInitiailizedError if version_exists?
      create_versions_table unless versions_table_exists?
    end

    def keyspace_exists?
      Cassie.cluster.keyspaces.map(&:name).any?{|k| k == Cassie::Schema.schema_keyspace}
    end

    def record_migration(migration)
      version = build_version(migration.version.number, migration.version.description)
      InsertVersionQuery.new(version: version).execute
    end

    def forget_migration(migration)
      id = versions.find{|v| v == migration.version}.id
      DeleteVersionQuery.new(id: id).execute
    end

    protected

    def default_version
      '0.0.1.0'
    end

    def version_exists?
      !!Cassie::Schema.version
    rescue Cassie::Schema::UninitializedError
      false
    end

    def versions_table_exists?
      !!SelectVersionsQuery.new(limit: 1).fetch
    rescue Cassandra::Errors::InvalidError
      false
    end

    def build_version(number, description)
      id = Cassandra::TimeUuid::Generator.new.now
      migrator = Etc.getlogin rescue '<unknown>'
      migrated_at = Time.now
      Version.new(number, description, id, migrator, migrated_at)
    end

    def create_schema_keyspace
      CreateSchemaKeyspaceQuery.new.execute
    end

    def create_versions_table
      CreateVersionsTableQuery.new.execute
    end

    def uninitialized_error
      UninitializedError.new(uninitialized_message)
    end

    def uninitialized_message
      "Cassie Schema Versions table not found at '#{schema_keyspace}.#{versions_table}'. Create a migration or initialize your schema to enable versioned migration support."
    end
  end
end