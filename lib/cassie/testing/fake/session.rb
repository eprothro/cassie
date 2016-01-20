require_relative 'result'
require_relative 'prepared_statement'

module Cassie::Testing::Fake
  class Session
    attr_reader :last_statement
    attr_accessor :rows

    def execute(statement, *args)
      @last_statement = statement
      Result.new(statement, rows: rows)
    end

    def prepare(statement)
      PreparedStatement.new(statement)
    end
  end
end