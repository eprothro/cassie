require_relative 'result'
require_relative 'prepared_statement'

module Cassie::Testing::Fake
  class Session
    attr_reader :last_statement, :query_count
    attr_accessor :rows

    def initialize
      reset_query_count!
    end

    def execute(statement, args={})
      @last_statement = statement
      @query_count += 1
      Result.new(statement, args.merge(rows: rows))
    end

    def prepare(statement)
      PreparedStatement.new(statement)
    end

    def reset_query_count!
      @query_count = 0
    end
  end
end