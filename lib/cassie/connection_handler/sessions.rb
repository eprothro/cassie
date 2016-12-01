module Cassie::ConnectionHandler
  module Sessions
    require_relative 'sessions/instrumentation'
    extend ActiveSupport::Concern

    included do
      include Instrumentation
    end

    def sessions
      @sessions ||= {}
    end

    def session(keyspace=self.keyspace)
      sessions[keyspace] || initialize_session(keyspace)
    end

    protected

    def initialize_session(keyspace)
      @sessions[keyspace] = cluster.connect(keyspace)
    end
  end
end