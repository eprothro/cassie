module Cassie::Statements::Execution
  module Instrumentation

    def execute(*args)
      Cassie.instrumenter.instrument("cassie.cql.execution") do |payload|
        # If an exception happens during instrumentation
        # the payload will have a key :exception with an
        # array of two elements as value: a string with
        # the name of the exception class, and the exception message.
        # The :exception_object key of the payload will have the exception itself as the value.
        execution_val = super #execution populates #result
        payload[:execution_info] = result.execution_info if result.respond_to?(:execution_info)
        execution_val
      end
    end
  end
end


