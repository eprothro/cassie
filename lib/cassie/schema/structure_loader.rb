module Cassie::Schema

  # @deprecated Use {Cassie::Schema::SchemaLoader} instead
  class StructureLoader
    attr_reader :source_path


    def initialize(opts={})
      @source_path = opts[:source_path] || default_source_path
    end

    def load
      args = ["-f", source_path]
      runner = Cassie::Support::SystemCommand.new("cqlsh", args)

      runner.run
      raise runner.failure_message unless runner.success?
    end

    protected

    def default_source_path
      Cassie::Schema.paths[:schema_file]
    end
  end
end