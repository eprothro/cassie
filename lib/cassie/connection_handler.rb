module Cassie
  # Extend Cassie::ConnectionHandler to provide cluster and session
  # cacheing in line with Cassandra best practices.
  #
  # The base class must implement `configuration` and `keyspace` methods.
  module ConnectionHandler
    require_relative 'connection_handler/cluster'
    require_relative 'connection_handler/sessions'
    require_relative 'connection_handler/logging'

    include Cluster
    include Sessions

    def self.extended(extender)
      #TODO: raise if extender doesn't
      #      respond to configuration
      #      and keyspace
    end
  end
end
