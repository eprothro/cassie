module Cassie::ConnectionHandler
  module Sessions

    def sessions
      @sessions ||= {}
    end

    def session(_keyspace=self.keyspace)
      sessions[_keyspace] || connect(_keyspace)
    end

    protected

    def connect(_keyspace)
      @sessions[_keyspace] = cluster.connect(_keyspace)
    end
  end
end