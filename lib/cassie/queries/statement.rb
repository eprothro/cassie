require 'active_support/core_ext/string/filters'
require 'active_support/hash_with_indifferent_access'
require_relative 'statement/execution'
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
      include Execution
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

    # returns a CQL string, or a Cassandra::Statement
    # that is ready for execution
    def statement
      Cassandra::Statements::Simple.new(*build_cql_and_bindings)
    end

    protected

    def build_cql_and_bindings
      if self.class.type
        send "build_#{self.class.type}_cql_and_bindings"
      else
        raise "No statement type has been declared. Call `.select`, `.update`, `.delete`, or `.insert` to set query type."
      end
    end

    private

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
