module Cassie::ConnectionHandler::Logging
  class SessionConnectEvent < ActiveSupport::Notifications::Event

    def keyspace
      payload[:keyspace] || "[none]"
    end

    def message
      {
        event: "cassie.session.connect",
        duration: duration.round(1),
        keyspace: keyspace
      }.extend(Inspector)
    end

    module Inspector
      def inspect
        "(#{fetch(:duration).round(1)}ms) Session opened to Cassandra cluster. Keyspace: #{fetch(:keyspace)}"
      end

      def to_s
        inspect
      end
    end
  end
end