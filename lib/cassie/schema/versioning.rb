require_relative 'migration'
require_relative 'version_writer'
require_relative 'version_file_loader'
require_relative 'version_object_loader'
require_relative 'migrator'

module Cassie::Schema
  require_relative 'version'

  class AlreadyInitiailizedError < StandardError; end
  class UninitializedError < StandardError; end

  module Versioning

    def version
      SelectVersionsQuery.new.fetch_first || Version.new('0')
    rescue Cassandra::Errors::InvalidError
      raise uninitialized_error
    end

    def applied_versions
      @applied_versions ||= load_applied_versions
    end

    def initialize_versioning
      create_schema_keyspace unless keyspace_exists?
      raise Cassie::Schema::AlreadyInitiailizedError if version_exists?
      create_versions_table unless versions_table_exists?
    end

    def keyspace_exists?
      Cassie.cluster.keyspaces.map(&:name).any?{|k| k == Cassie::Schema.schema_keyspace}
    end

    def record_version(version)
      InsertVersionQuery.new(version: version).execute
    end

    def forget_version(version)
      DeleteVersionQuery.new(id: version.id).execute
    end

    def migration_files
      Dir[root.join(paths["migrations_directory"], "[0-9]*_*.rb")]
    end

    def local_versions
      @local_versions ||= load_local_versions
    end

    def next_local_version(bump_type=nil)
      version = local_versions.max || Version.new('0')
      version.next(bump_type)
    end

    protected

    def default_version
      '0.0.1.0'
    end

    def load_applied_versions
      database_versions.tap do |versions|
        versions.each{|v| VersionObjectLoader.new(v).load }
      end
    rescue Cassandra::Errors::InvalidError
      raise uninitialized_error
    end

    def database_versions
      SelectVersionsQuery.new.fetch
    end

    def load_local_versions
      migration_files.map do |filename|
        VersionFileLoader.new(filename).load
      end.sort!
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