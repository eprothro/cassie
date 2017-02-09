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

    # The current schema version
    # @returns [Version]
    def version
      SelectVersionsQuery.new.fetch_first || Version.new('0')
    rescue Cassandra::Errors::InvalidError
      raise uninitialized_error
    end

    # The versions that have been migrated up for the Cassandra database
    # This lists the versions stored in the persistence layer, in reverse
    # chronological order (newest first).
    # @return [Enumerable<Version>]
    def applied_versions
      @applied_versions ||= load_applied_versions
    end

    # Create the keyspace and table for tracking schema versions
    # in the Cassandra database
    # @return [void]
    def initialize_versioning
      create_schema_keyspace unless keyspace_exists?
      raise Cassie::Schema::AlreadyInitiailizedError if version_exists?
      create_versions_table unless versions_table_exists?
    end

    # Record a version in the schema version store.
    # This should only be done if the version has been sucesfully migrated
    # @return [Boolean] whether succesfull or not
    def record_version(version)
      InsertVersionQuery.new(version: version).execute
      @applied_versions = nil
    end

    # Remove the version from the schema version store.
    # This should only be done if the version has been sucesfully reverted
    # @param [Version] version A persisted version
    # @return [Boolean] whether succesfull or not
    def forget_version(version)
      DeleteVersionQuery.new(id: version.id).execute
      @applied_versions = nil
    end

    # Absolute paths to the migration files in the migration directory
    # @retun [Array<String>]
    def migration_files
      Dir[root.join(paths["migrations_directory"], "[0-9]*_*.rb")]
    end

    # Versions for the {#local_migrations}
    # If a migration is applied versions, the object for that
    # version will be the applied version, containing the full
    # information about the applied version
    # @return [Enumeration<Version>]
    def local_versions
      @local_versions ||= load_local_versions
    end

    # A version with a version number after
    # the most recent {#local_version}.
    # @param [Symbol, nil] bump_type Which semantic version to bump
    # @option bump_type [Symbol] :build Bump the build version
    # @option bump_type [Symbol] :patch Bump the patch version, set build to 0
    # @option bump_type [Symbol] :minor Bump the minor version, set patch and build to 0
    # @option bump_type [Symbol] :major Bump the major version, set minor, patch, and build to 0
    # @option bump_type [nil] nil Default, bumps patch, sets build to 0
    # @return [Version] The initialized, bumped version
    def next_local_version(bump_type=nil)
      version = local_versions.max || Version.new('0')
      version.next(bump_type)
    end

    protected

    def default_version
      '0.0.1.0'
    end

    def keyspace_exists?
      Cassie.keyspace_exists?(Cassie::Schema.schema_keyspace)
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
      CreateKeyspaceQuery.new(name: Cassie::Schema.schema_keyspace).execute
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