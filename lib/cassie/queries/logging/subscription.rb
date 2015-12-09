require_relative 'cql_execution_event'

module Cassie::Queries::Logging
  module Subscription
    extend ::ActiveSupport::Concern

    included do
      ActiveSupport::Notifications.subscribe('cql.execute') do |*args|
        # args:
        # name    # => String, name of the event (such as 'render' from above)
        # start   # => Time, when the instrumented block started execution
        # finish  # => Time, when the instrumented block ended execution
        # id      # => String, unique ID for this notification
        # payload # => Hash, the payload
        #             [:exception] => if raised during event
        unless args.last[:exception]
          logger.debug(CqlExecutionEvent.new(*args).message)
        end
      end
    end
  end
end
