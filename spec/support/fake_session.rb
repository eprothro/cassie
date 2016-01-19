#TODO: figure out a better way to do a test harness
module CassandraFake
  class BoundStatement
    attr_reader :statement

    def initialize(statement)
      @statement = statement
    end

    def bind(params)
      statement
    end
  end

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

  class Session
    def execute(statement, *args)
      Result.new(statement)
    end

    def prepare(statement)
      BoundStatement.new(statement)
    end
  end
end

class Cassie::Query
  def self.session
    @session ||= CassandraFake::Session.new
  end
end