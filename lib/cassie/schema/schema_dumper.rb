module Cassie::Schema
  require_relative 'queries'

  class SchemaDumper
    # The location to dump the ruby file
    attr_reader :destination_path

    # The keyspace that will be extracted
    # and replaced with +#{default_keyspace}+ upon dumping
    attr_reader :keyspace

    def initialize(opts={})
      @destination_path = opts[:destination_path] || default_destination_path
      @keyspace = Cassie.configuration[:keyspace]
    end

    # The stream to dump the source to
    def stream
      @stream ||= begin
        prepare_stream
        File.open(destination_path, "w+")
      end
    end

    # Dump the CQL for the current environment's keyspace,
    # the schema metadata keyspace, and the versions rows
    # that are currently in the schema versions table.
    def dump
      stream << <<-EOS
# This file describes the keyspace-agnostic schema
# for this application's environments.
#
# It is the definitive source of the current state
# of the schema and should not be modified directly.
#
# It is strongly recommened that this schema file be checked into source control.
#
# Use `cassie` commands to apply this schema to a particular environment:
# * Load this schema with `cassie schema:load`
# * Reset the schema to this definition with `cassie schema:reset`
Cassie::Schema.define do

EOS
      stream << "  create_schema <<-EOS\n"
      stream << "#{keyspace_agnostic_cql}\n"
      stream << "EOS\n"
      stream << "\n\n"
      versions.each do |v|
        stream << "  record_version #{version_arg_str(v)}\n"
      end
      stream << "end\n"

      close_stream
    end

    def versions_table_name
      "#{Cassie::Schema.schema_keyspace}.#{Cassie::Schema.versions_table}"
    end

    def destination_path
      @destination_path || raise("Unconfigured schema file path: `Cassie::Schema.paths[:schema_file]` is empty")
    end

    protected

    # Fetch the keyspace agnostic CQL ruby string that can be used to
    # recreate the keyspace. The keyspace value is replaced
    # with +#{default_keyspace}+
    # @return [String] A ruby string with keyspace interpolated CQL commands
    # @raise [RuntimeError] if the {Cassie.configuration[:keyspace]} keyspace could not be described.
    def keyspace_agnostic_cql
      @keyspace_structure ||= begin
        args = ["-e", "'DESCRIBE KEYSPACE #{keyspace}'"]
        runner = Cassie::Support::SystemCommand.new("cqlsh", args)
        runner.succeed

        runner.output.gsub(keyspace, '#{default_keyspace}').strip
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

    def version_arg_str(version)
      <<-EOS.strip
"#{version}", "#{version.description}", "#{version.id}", "#{version.executor}", "#{version.executed_at.try(:iso8601, 6)}"
EOS
    end
  end
end