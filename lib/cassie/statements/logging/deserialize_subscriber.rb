require_relative 'deserialize_event'

module Cassie::Statements::Logging
  class DeserializeSubscriber

    def call(*args)
      # don't log if instrumentation failed
      unless args.last[:exception]
        logger.debug(DeserializeEvent.new(*args).message)
      end
    end

    def logger
      Cassie::Statements.logger
    end

    ActiveSupport::Notifications.subscribe('cassie.deserialize', new)
  end
end