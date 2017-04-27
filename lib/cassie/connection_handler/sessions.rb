module Cassie::ConnectionHandler
  module Sessions
    require_relative 'sessions/instrumentation'
    extend ActiveSupport::Concern

    included do
      include Instrumentation
      CREATE_SESSION_LOCK = Mutex.new
    end

    # Sessions cache containing sessions that
    # have been opened to the {#cluster}
    # @return [Hash{String => Cassandra::Session}] The underlying driver sessions, keyed by keyspaced name
    # @!parse attr_reader :sessions
    def sessions
      @sessions ||= {}
    end

    # Fetches a session from the sessions cache.
    # If no session has been opened to the requested keyspace
    # a new session is created to the {#cluster} and cached.
    # @note this method is thread-safe, only one session will be opened
    #   per keyspace regardless of how many threads are accessing.
    # @note there is no connection pooling happening here, +cassandra_driver+
    #   manages per node connection pools within the +Session+ object.
    # @param [String] keyspace The keyspace used for session scope. If +nil+, session will not be scoped (scoped to global space).
    # @return [Cassandra::Session]
    def session(keyspace=self.keyspace)
      return sessions[keyspace] || initialize_session(keyspace)
    end

    protected

    # thread safe initialization
    # only one session should be initialized
    # per keyspace
    def initialize_session(keyspace)
      CREATE_SESSION_LOCK.synchronize do
        # check to see if another thread
        # initialized the session while
        # we waited on lock to be available
        # e.g. this ||= is critical
        @sessions[keyspace] ||= cluster.connect(keyspace)
      end
    end
  end
end