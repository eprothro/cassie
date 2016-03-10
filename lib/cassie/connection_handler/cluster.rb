require 'benchmark'

module Cassie::ConnectionHandler
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

        logger.info "Connected to Cassandra cluster #{config[:hosts]} (#{sec.round(3)}s)"
        _cluster
      end
    end
  end
end