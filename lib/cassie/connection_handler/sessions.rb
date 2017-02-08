module Cassie::ConnectionHandler
  module Sessions
    require_relative 'sessions/instrumentation'
    extend ActiveSupport::Concern

    included do
      include Instrumentation
    end

    # Sessions cache containint sessions that
    # have been opened to the {#cluster}
    # @return [Hash{String => Cassandra::Session}] The underlying driver sessions, keyed by keyspaced name
    # @!parse attr_reader :sessions
    def sessions
      @sessions ||= {}
    end

    # Fetches a session from the sessions cache.
    # If no session has been opened to the requested keyspace
    # a new session is created to the {#cluster} and cached.
    # @param [String] keyspace The keyspace used for session scope. If +nil+, session will not be scoped (scoped to global space).
    # @return Cassandra::Session
    def session(keyspace=self.keyspace)
      sessions[keyspace] || initialize_session(keyspace)
    end

    protected

    def initialize_session(keyspace)
      @sessions[keyspace] = cluster.connect(keyspace)
    end
  end
end