require_relative 'loading'

module Cassie::Configuration
  #TODO: proper rdoc
  # Extend a class with Core to enable configuration management
  module Core
    include Loading

    attr_writer :keyspace

    def self.extended(extender)
      extender.paths["cluster_configurations"] = "config/cassandra.yml"
    end

    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV["CASSANDRA_ENV"] || ENV["RACK_ENV"] || "development")
    end

    def env=(val)
      @env = ActiveSupport::StringInquirer.new(val)
    end

    def paths
      @paths ||= {}.with_indifferent_access
    end

    def configurations
      @configurations ||= cluster_configurations
    end

    def configurations=(val)
      if val && defined?(@configuration)
        puts "WARNING: Setting `configurations` will have no effect on what config is used right now. `#{self}.configuration` has previously been set explicitly and will be used instead."
      end
      @configurations = val
    end

    def configuration
      return @configuration if defined?(@configuration)
      configurations[env]
    end

    def configuration=(val)
      @configuration = val
    end

    def keyspace
      return @keyspace if defined?(@keyspace)
      @keyspace = configuration[:keyspace]
    end

  end
end
