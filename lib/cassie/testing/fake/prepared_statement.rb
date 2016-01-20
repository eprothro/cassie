module Cassie::Testing::Fake
  class PreparedStatement
    attr_reader :statement

    def initialize(statement)
      @statement = statement
    end

    def bind(params)
      statement
    end
  end
end