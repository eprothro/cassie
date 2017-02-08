module Cassie
  # Extend Cassie::ConnectionHandler to provide cluster and session
  # cacheing in line with Cassandra best practices.
  #
  # The extending class must provide two methods
  # that will be used by the connection handler for connections:
  # * +self.configuration+
  #   * A configuration hash defining cluster options per environment
  #   * Used when connecting through +cassandra_driver+
  #   * See [Configuration::Core] for a sample implementation with a .yml back-end
  # * +self.keyspace+
  #   * The default keyspace to connect to when none is specified for a session.
  module ConnectionHandler
    require_relative 'connection_handler/cluster'
    require_relative 'connection_handler/sessions'
    require_relative 'connection_handler/logging'

    include Cluster
    include Sessions
  end
end
