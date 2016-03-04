module Cassie
  #TODO: proper rdoc
  # Assumes module responds to `configuration`, `keyspace`, and `cluster`
  module ConnectionHandler
    require_relative 'connection_handler/cluster'
    require_relative 'connection_handler/sessions'

    include Cluster
    include Sessions

    def self.extended(extender)
      #TODO: raise if extender doesn't
      #      respond to configuration
      #      and keyspace
    end
  end
end
