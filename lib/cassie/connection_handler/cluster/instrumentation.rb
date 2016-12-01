module Cassie::ConnectionHandler::Cluster
  module Instrumentation

    protected

    def initialize_cluster
      Cassie.instrumenter.instrument("cassie.cluster.connect") do |payload|
        super.tap do |cluster|
          payload[:hosts] = cluster.hosts
          payload[:name] = cluster.name
        end
      end
    end
  end
end