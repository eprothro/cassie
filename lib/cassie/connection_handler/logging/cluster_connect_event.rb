module Cassie::ConnectionHandler::Logging
  class ClusterConnectEvent < ActiveSupport::Notifications::Event

    def hosts
      payload[:hosts] || []
    end

    def ips
      hosts.map{ |h| h.ip.to_s }
    end

    def message
      {
        event: "cassie.cluster.connect",
        duration: duration.round(1),
        hosts: ips,
        name: payload[:name]
      }.extend(Inspector)
    end

    module Inspector
      def inspect
        "(#{fetch(:duration).round(1)}ms) Connected to Cassandra cluster. #{fetch(:name)}: #{fetch(:hosts)}"
      end

      def to_s
        inspect
      end
    end
  end
end