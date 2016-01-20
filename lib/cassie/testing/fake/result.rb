require_relative 'execution_info'

module Cassie::Testing::Fake
  class Result
    attr_accessor :rows, :statement

    def initialize(statement, opts={})
      @statement = statement
      @rows = opts[:rows]
    end

    def execution_info
      ExecutionInfo.new(statement)
    end

    def rows
      @rows || []
    end

    def empty?
      rows.empty?
    end
  end
end