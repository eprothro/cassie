module Cassie::Statements::Execution
  module Instrumentation

    def execute(*args)
      Cassie.instrumenter.instrument("cassie.cql.execution") do |payload|
        execution_val = super #execution populates #result

        payload[:execution_info] = result.execution_info if result.respond_to?(:execution_info)
        execution_val
      end
    end
  end
end


