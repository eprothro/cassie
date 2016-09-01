module Cassie::Testing::Fake
  class PreparedStatement
    attr_reader :original_statement

    def initialize(statement)
      @original_statement = statement
    end

    # Creates a statement bound with specific arguments
    #
    # Cassandra does type checking against connection version
    # which requires a connection.
    #
    # Note: this fake implementation returns a simple statement
    # not a bound statement. Implementing the latter would require
    # faking the metadata on the prepared statement object
    # which I don't have reason to do yet
    def bind(new_params)
      fake_bound = original_statement.clone
      fake_bound.instance_variable_set :@params, new_params
      fake_bound
    end
  end
end