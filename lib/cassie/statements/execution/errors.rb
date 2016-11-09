module Cassie::Statements

  class ExecutionError < StandardError
    attr_reader :statement

    def initialize(statement)
      @statement = statement
      super
    end

    def message
      "Failed to execute statement: #{cql}"
    end

    private

    def cql
      case
      when statement.respond_to?(:to_cql)
        statement.to_cql
      when statement.result && statement.result.execution_info && statement.result.execution_info.statement
        statement.result.execution_info.statement.to_cql
      when statement.respond_to?(:statement)
        statement.statement.to_s
      else
        statement.to_s
      end
    end
  end
end