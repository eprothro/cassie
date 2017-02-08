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

    # The cluster connection and metadata. This attribute is
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

    protected

    def initialize_cluster
      Cassandra.cluster(configuration.try(:symbolize_keys))
    end
  end
end