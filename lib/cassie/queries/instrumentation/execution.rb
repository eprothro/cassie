module Cassie::Queries::Instrumentation
  module Execution

    def execute
      instrumenter.instrument("cassie.cql.execution") do |payload|
        execution_val = super #execution populates #result

        payload[:execution_info] = result.execution_info if result.respond_to?(:execution_info)
        execution_val
      end
    end
  end
end


