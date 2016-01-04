require 'active_support/core_ext/string/filters'
require_relative 'statement/preparation'
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
      include Selection
      include Deleting
      include Updating
      include Inserting

      attr_reader :result

      class << self
        attr_accessor :table
        attr_accessor :identifier
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
      if identifier
        send "build_#{identifier}_cql_and_bindings"
      else
        [cql, bindings]
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

    def identifier
      self.class.identifier
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
