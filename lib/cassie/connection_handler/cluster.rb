module Cassie::ConnectionHandler
  # ## Cassie::ConnectionHandler::Cluster
  #
  # Adds cluster instance configuration and memoization.
  #
  # Include in any class or module that responds to `configuration` with
  # a cassandra cluster options hash.
  module Cluster
    require_relative 'cluster/instrumentation'
    extend ActiveSupport::Concern

    included do
      include Instrumentation
    end

    # The cluster connection and metadata. This cluster connection is
    # lazy-loaded, not calling out to Cassandra until it is first
    # accessed. The single cluster object is cached for the entire process.
    # @return [Cassandra::Cluster] The underlying driver cluster object
    # @!parse attr_reader :cluster
    def cluster
      # Cassandra::cluster parses suppored
      # options from the passed hash, no need
      # to validate/transform ourselves yet
      @cluster ||= initialize_cluster
    end

        # @param [String, Symbol] name The keyspace name to search for
    # @return [Boolean] indicating if the cluster has the keyspace defined
    def keyspace_exists?(name)
      cluster.keyspaces.map(&:name).any?{|k| k.to_s == name.to_s}
    end

    # @param [String, Symbol] name The table name to search for. If the name
    #   includes a '.', it is assumed to be a fully qualified table name. Otherwise
    #   the table name will be searched for in the current namespace
    # @return [Boolean] indicating if the cluster has the keyspace defined
    def table_exists?(name)
      keyspaces = {}
      name = "#{keyspace}.#{name}" unless name.to_s.include? "."
      matches = name.match(/(.*)\.(.*)/)
      space = matches[1]
      table = matches[2]
      cluster.keyspaces.each {|k| keyspaces[k.name.to_s] = k }

      return false unless keyspaces.has_key?(space)
      keyspaces[space].tables.map(&:name).any?{|t| t.to_s == table}
    end

    protected

    def initialize_cluster
      Cassandra.cluster(configuration.try(:symbolize_keys))
    end
  end
end