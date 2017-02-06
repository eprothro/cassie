module Cassie::Configuration
  module Loading

    def cluster_configurations
      path = paths["cluster_configurations"]

      file = begin
        File.new(path)
      rescue StandardError
        raise MissingClusterConfigurations.new(path)
      end

      require "yaml"
      require "erb"

      hash = YAML.load(ERB.new(file.read).result) || {}
      hash.with_indifferent_access
    rescue StandardError => e
      raise e, "Cannot load Cassandra cluster configurations:\n#{e.message}", e.backtrace
    end
  end

  class MissingClusterConfigurations < StandardError
    attr_reader :path

    def initialize(path)
      @path = path
      super(build_message)
    end

    def build_message
      msg = "Could not load cassandra cluster configurations. "
      msg += "No cluster configurations exists at #{path}.\n"
      msg += generation_instructions
      msg + ", or configure the correct path via Cassie::Configuration.paths['cluster_configurations'] = <path>."
    end

    def generation_instructions
      "Generate #{path} by running `cassie configuration:generate` or `cassie configuration:generate <relative or absolute path>.yml`"
    end
  end
end
