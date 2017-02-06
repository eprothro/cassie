module Cassie::Testing::Fake
  class ExecutionInfo
    attr_reader :statement, :consistency

    def initialize(statement)
      @statement = statement
    end

    def bind(_params)
      statement
    end

    def trace
      nil
    end

    def consistency
      :local_one
    end
  end
end