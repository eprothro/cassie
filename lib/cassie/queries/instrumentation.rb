module Cassie::Queries
  module Instrumentation
    extend ::ActiveSupport::Concern

    def execute
      instrument { super }
    end

    def instrument #:nodoc:
      instrumenter.instrument("cql.execute") do |payload|
        execution_val = yield # execution populates #result
        payload[:execution_info] = result.try(:execution_info)
        execution_val
      end
    end

    protected

    def instrumenter
      ActiveSupport::Notifications
    end
  end
end
