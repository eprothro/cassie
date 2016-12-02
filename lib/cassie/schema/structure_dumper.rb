module Cassie::Schema
  require_relative 'queries'

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

    def structure
      @structure ||= begin
        args = ["-e", "'DESCRIBE SCHEMA'"]
        runner = Cassie::Support::CommandRunner.new("cqlsh", args)
        runner.run

        raise runner.failure_message unless runner.success?

        runner.output
      end
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

    def dump
      stream << structure
      stream << "\n\n"
      stream << versions_insert_cql
      stream << "\n"

      close_stream
    end

    def versions_table_name
      "cassie_schema.versions"
    end

    def destination_path
      @destination_path || raise("Unconfigured schema structure path: `Cassie::Schema.paths[:schema_structure]` is empty")
    end

    protected

    def versions_query
      SelectVersionsQuery.new
    end

    def default_destination_path
      Cassie::Schema.paths[:schema_structure]
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
      msg = "WARNING: Cassie Schema Versions table not found at '#{versions_table_name}'. Create a migration, or initialize your schema for versioned migration support."
      msg << "\n\t"
      msg << error.message.split("\n").join("\n\t")
      logger.warn(msg)
    end

    def logger
      Cassie.logger
    end
  end
end