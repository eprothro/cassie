require 'benchmark'

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
      _session = nil

      sec = Benchmark.realtime do
        _session = cluster.connect(_keyspace)
      end

      logger.info "Session opened to Cassandra[#{_keyspace}] (#{sec.round(3)}s)"
      @sessions[_keyspace] = _session
    end
  end
end