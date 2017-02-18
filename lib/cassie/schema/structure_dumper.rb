module Cassie::Schema
  require_relative 'queries'

  # @deprecated Use {Cassie::Schema::SchemaDumper} instead
  class StructureDumper
    attr_reader :destination_path

    def initialize(opts={})
      @destination_path = opts[:destination_path] || default_destination_path
    end

    def stream
      @stream ||= begin
        prepare_stream
        File.open(destination_path, "w+")
      end
    end

    # Fetch the CQL that can be used to recreate the current environment's keyspace
    # @return [String] CQL commands
    # @raise [RuntimeError] if the {Cassie.configuration[:keyspace]} keyspace could not be described.
    def keyspace_structure
      @keyspace_structure ||= begin
        args = ["-e", "'DESCRIBE KEYSPACE #{Cassie.configuration[:keyspace]}'"]
        runner = Cassie::Support::SystemCommand.new("cqlsh", args)
        runner.succeed

        runner.output
      end
    end

    # Fetch the CQL that can be used to recreat the schema metadata keyspace,
    # if it has been defined. If it could not be fetched (likely because it doesn't exist),
    # an empty string is returned.
    # @return [String] CQL commands
    def schema_meta_structure
      CreateVersionsTableQuery.new.to_cql
    end

    def versions
      @versions ||= begin
        versions_query.fetch
      rescue Cassandra::Errors::InvalidError => e
        log_versions_not_found(e)
        []
      end
    end

    def versions_insert_cql
      inserts = versions.map do |v|
        InsertVersionQuery.new(version: v).to_cql
      end
      inserts.join("\n")
    end

    # Dump the CQL for the current environment's keyspace,
    # the schema metadata keyspace, and the versions rows
    # that are currently in the schema versions table.
    def dump
      stream << keyspace_structure
      stream << schema_meta_structure
      stream << "\n\n"
      stream << versions_insert_cql
      stream << "\n"

      close_stream
    end

    def versions_table_name
      "#{Cassie::Schema.schema_keyspace}.#{Cassie::Schema.versions_table}"
    end

    def destination_path
      @destination_path || raise("Unconfigured schema file path: `Cassie::Schema.paths[:schema_file]` is empty")
    end

    protected

    def versions_query
      SelectVersionsQuery.new
    end

    def default_destination_path
      Cassie::Schema.paths[:schema_file]
    end

    def prepare_stream
      dir = File.dirname(destination_path)
      Dir.mkdir(dir) unless File.directory?(dir)
    end

    def close_stream
      stream.close
      @stream = nil
    end

    def log_versions_not_found(error)
      msg = "WARNING: Cassie Schema Versions table not found at '#{versions_table_name}'. Initialize your schema with `cassie schema:init` or `cassie:migrations:import` for versioned migration support."
      msg << "\n\t- "
      msg << error.message.split("\n").join("\n\t- ")
      logger.warn(msg)
    end

    def logger
      Cassie.logger
    end
  end
end