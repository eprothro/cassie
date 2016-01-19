#TODO: figure out a better way to do a test harness
module CassandraFake
  class PreparedStatement
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
    attr_reader :last_statement
    attr_accessor :next_rows

    def execute(statement, *args)
      @last_statement = statement
      Result.new(statement, rows: next_rows)
    end

    def prepare(statement)
      PreparedStatement.new(statement)
    end
  end
end

class Cassie::Query
  def self.session
    @session ||= CassandraFake::Session.new
  end
end