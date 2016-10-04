require 'active_support/core_ext/string/filters'
require 'active_support/hash_with_indifferent_access'

module Cassie::Statements
  # Include Statement to provide support for a
  # `statement` method returning a `Cassandra::Statements::Simple`
  # statement with positional arguments.
  #
  # `type` and `table` attributes are also added,
  # providing an extension interface for building
  # cql and bindings for different statement types.
  module Statement
    require_relative 'statement/preparation'

    class Invalid < StandardError; end

    extend ::ActiveSupport::Concern

    included do
      include Preparation

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
