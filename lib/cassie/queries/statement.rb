require 'active_support/core_ext/string/filters'
require_relative 'statement/preparation'
require_relative 'statement/callbacks'
require_relative 'statement/limiting'
require_relative 'statement/pagination'
require_relative 'statement/selection'
require_relative 'statement/deleting'
require_relative 'statement/updating'
require_relative 'statement/inserting'


module Cassie::Queries
  module Statement
    # https://cassandra.apache.org/doc/cql3/CQL.html#selectStmt
    extend ::ActiveSupport::Concern

    included do
      include Preparation
      include Callbacks
      include Limiting
      include Pagination
      include Selection
      include Deleting
      include Updating
      include Inserting

      attr_reader :result

      class << self
        attr_accessor :table
        attr_accessor :type
      end
    end

    def table
      self.class.table
    end

    # Executes the statment, populates result
    # returns true or false indicating a successful execution or not
    def execute
      @result = session.execute(statement)
      execution_successful?
    end

    # returns a CQL string, or a Cassandra::Statement
    # that is ready for execution
    def statement
      Cassandra::Statements::Simple.new(*build_cql_and_bindings)
    end

    protected

    def build_cql_and_bindings
      if type
        send "build_#{type}_cql_and_bindings"
      else
        raise "No statement type has been declared. Call `.select`, `.update`, `.delete`, or `.insert` to set query type."
      end
    end

    def execution_successful?
      #TODO: rethink this, it knows too much
      raise "execution not complete, no results to parse" unless result

      # empty select
      return true if result.empty?

      # failed upsert
      return false if (!result.rows.first["[applied]"].nil?) && (result.rows.first["[applied]"] == false)

      true
    end

    private

    def type
      self.class.type
    end

    def eval_if_opt?(value)
      case value
      when nil
        true # if is true by default
      when Symbol
        !!send(value)
      when String
        !!eval(value)
      else
        !!value
      end
    end

    def eval_value_opt(value)
      case value
      when Symbol
        send(value)
      when String
        eval(value)
      else
        value
      end
    end
  end
end
