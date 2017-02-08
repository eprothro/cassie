require_relative 'loading'

module Cassie::Configuration
  # Extend a class with Core to add configuration management
  # methods and attributes
  module Core
    include Loading

    # The currently selected keyspace.
    # If no keyspace has been explicitly set, then
    # the default +:keyspace+ from {#configuration} is used.
    attr_accessor :keyspace

    # @!visibility private
    def self.extended(extender)
      extender.paths["cluster_configurations"] = "config/cassandra.yml"
    end

    # The currently active environment.
    # Used to select which configuration will be used
    # @!parse attr_accessor :env
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV["CASSANDRA_ENV"] || ENV["RACK_ENV"] || "development")
    end

    def env=(val)
      @env = ActiveSupport::StringInquirer.new(val)
    end

    # Paths used for configuration loading.
    #
    # @return [Hash]
    #   * +:cluster_configurations+ - The .yml file defining the configuration for your cluster for various environments.
    def paths
      @paths ||= {}.with_indifferent_access
    end

    # The cluster configurations available for all environments
    # @return [Hash{String => [Hash]}] Cluster configurations, keyed by environment.
    # @!parse attr_accessor :configurations
    def configurations
      @configurations ||= cluster_configurations
    end

    def configurations=(val)
      if val && defined?(@configuration)
        puts "WARNING: Setting `configurations` will have no effect on what config is used right now. `#{self}.configuration` has previously been set explicitly and will be used instead."
      end
      @configurations = val
    end

    # The currently active configuration used
    # for initializing new cluster connections.
    # If none has been set, the configuration for the
    # current {#env} is used from {#configuration}
    #
    # Note: setting a {#configuration} value will override
    # the {#configurations} attribute, rendering it useless
    # @return [Hash{String,Symbol => Object}] Hash of +cassandra-driver+ supported cluster configuration attributes
    # @!parse attr_accessor :configuration
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
