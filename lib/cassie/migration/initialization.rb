module Cassie::Migration

  class AlreadyInitiailizedError < StandardError; end
  class UninitializedError < StandardError; end

  module Initialization
    require 'etc'

    extend ActiveSupport::Concern

    module ClassMethods

      def initialize_versioning(version=default_version)
        create_schema_keyspace unless keyspace_exists?
        raise Cassie::Migration::AlreadyInitiailizedError if version_exists?
        create_versions_table unless versions_table_exists?
        insert_version(build_version(version, 'initial schema'))
      end

      def keyspace_exists?
        Cassie.cluster.keyspaces.map(&:name).any?{|k| k == Cassie::Migration.schema_keyspace}
      end

      def version_exists?
        !!Cassie::Migration.version
      rescue Cassie::Migration::UninitializedError
        false
      end

      def versions_table_exists?
        !!SelectVersionsQuery.new(limit: 1).fetch
      rescue Cassandra::Errors::InvalidError
        false
      end

      def build_version(version_number, description)
        id = Cassandra::TimeUuid::Generator.new.now
        migrator = Etc.getlogin rescue '<unknown>'
        migrated_at = Time.now
        Version.new(id, version_number, description, migrator, migrated_at)
      end

      def insert_version(version)
        InsertVersionQuery.new(version: version).execute
      end

      protected

      def default_version
        '0.1.0'
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
end
