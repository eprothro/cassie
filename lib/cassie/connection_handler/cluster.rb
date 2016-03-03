module Cassie::ConnectionHandler
  module Cluster

    def cluster
      # Cassandra::cluster parses suppored
      # options from the passed hash, no need
      # to validate/transform ourselves yet
      @cluster ||= Cassandra.cluster(configuration)
    end
  end
end