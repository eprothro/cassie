require_relative 'cluster_connect_event'

module Cassie::ConnectionHandler::Logging
  class ClusterConnectSubscriber

    def call(*args)
      # don't log if instrumentation failed
      unless args.last[:exception]
        logger.info(ClusterConnectEvent.new(*args).message)
      end
    end

    def logger
      Cassie::Statements.logger
    end

    ActiveSupport::Notifications.subscribe('cassie.cluster.connect', new)
  end
end