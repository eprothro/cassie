require_relative 'migration_file'

module Cassie::Schema
  module CassandraMigrations
    class Importer
      # The source directory containing the +cassandra_migrations+ files.
      # Defaults to +db/cassandra_migrate+
      attr_accessor :source
      # The version the schema will rest at after importing.
      # Defaults to +0.1.0+ with a description of +Remove cassandra_migrations schema+
      attr_accessor :final_version
      # The migration files to be imported
      attr_accessor :migration_files

      def initialize(source_path=nil)
        @source = source_path || default_source_path
        @final_version = Cassie::Schema::Version.new("0.0.1.0", "Remove cassandra_migrations schema")
        @migration_files = find_migration_files
      end

      def import
        new_version = initial_version
        new_version.executor = "cassandra_migrations"
        new_version.executed_at = Time.now

        migration_files.each do |old_migration_file|
          new_version.id = Cassandra::TimeUuid::Generator.new.now
          new_version.description = old_migration_file.description.humanize
          writer = VersionWriter.new(new_version)
          # new_version will automatically find
          # the new cassie::schema::migration
          # that is built from the old file
          writer.migration_contents = old_migration_file.build_migration_class(new_version)
          writer.write
          Cassie::Schema.record_version(new_version)
          new_version = new_version.next
        end
      end

      protected

      def default_source_path
        "db/cassandra_migrate"
      end

      def find_migration_files
        paths = Dir.glob("#{absolute_source}/#{migration_template}")
        paths = Dir.glob("#{relative_source}/#{migration_template}") if paths.empty?
        raise_files_not_found if paths.empty?

        paths.map{ |path| MigrationFile.new(path) }
      end

      def absolute_source
        source
      end

      def relative_source
        File.join(root, source)
      end

      def root
        Dir.pwd
      end

      def migration_template
        # 20161206214301_initial_database.rb
        "[0-9]*_*.rb"
      end

      def raise_files_not_found
        raise "No Cassandra Migration files were found. Looked in #{absolute_source} and #{relative_source}. Check the path and try again."
      end

      def initial_version
        Cassie::Schema::Version.new("0.0.0.1")
      end
    end
  end
end