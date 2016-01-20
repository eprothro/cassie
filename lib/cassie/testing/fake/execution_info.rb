module Cassie::Testing::Fake
  class ExecutionInfo
    attr_reader :statement

    def initialize(statement)
      @statement = statement
    end

    def bind(params)
      statement
    end

    def trace
      nil
    end
  end
end