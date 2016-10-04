require_relative 'execute_event'

module Cassie::Statements::Logging
  class ExecuteSubscriber

    def call(*args)
      # don't log if instrumentation failed
      unless args.last[:exception]
        logger.debug(ExecuteEvent.new(*args).message)
      end
    end

    def logger
      Cassie::Statements.logger
    end

    ActiveSupport::Notifications.subscribe('cassie.cql.execution', new)
  end
end