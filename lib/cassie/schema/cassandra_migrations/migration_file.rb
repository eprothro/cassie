module Cassie::Schema
  module CassandraMigrations
    class MigrationFile

      attr_reader :filename, :source, :description

      def initialize(filename)
        @filename = filename
        @description = parse_description
      end

      # Builds a Cassie::Schema::Migration
      # from the CassandraMigrations migration file
      #
      # @return [String] source string of new migration class
      def build_migration_class(version)
        @source = load_source
        redefine_class(version.migration_class_name)
        define_new_migration_class
        version.migration_class_name.constantize
        @source
      ensure
        @source = nil #free for GC
      end

      protected

      def parse_description
        matches = File.basename(filename).match(/[0-9]*_(.*).rb$/).captures
        matches.first
      end

      def load_source
        File.read(filename)
      end

      def redefine_class(name)
        class_def = "class #{name} < Cassie::Schema::Migration"
        # class UserMigration < CassandraMigrations::Migration
        @source.sub!(/class\s.*<\s*CassandraMigrations::Migration/, class_def)
      end

      def define_new_migration_class
        # define class in context of Object
        # as a migration file does, rather
        # than in the current context
        Object.class_eval(@source)
      end
    end
  end
end