require 'benchmark'

module Cassie::ConnectionHandler
  # ## Cassie::ConnectionHandler::Cluster
  #
  # Adds cluster instance configuration and memoization.
  #
  # Include in any class or module that responds to `configuration` with
  # a cassandra cluster options hash.
  module Cluster

    def cluster
      # Cassandra::cluster parses suppored
      # options from the passed hash, no need
      # to validate/transform ourselves yet
      @cluster ||= begin
        _cluster = nil
        config = configuration.try(:symbolize_keys)

        sec = Benchmark.realtime do
          _cluster = Cassandra.cluster(config)
        end

        logger.info "(#{(sec*1000).round(2)}ms) Connected to Cassandra cluster #{config[:hosts]}"
        _cluster
      end
    end
  end
end