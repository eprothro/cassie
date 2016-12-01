require_relative 'session_connect_event'

module Cassie::ConnectionHandler::Logging
  class SessionConnectSubscriber

    def call(*args)
      # don't log if instrumentation failed
      unless args.last[:exception]
        logger.info(SessionConnectEvent.new(*args).message)
      end
    end

    def logger
      Cassie::Statements.logger
    end

    ActiveSupport::Notifications.subscribe('cassie.session.connect', new)
  end
end