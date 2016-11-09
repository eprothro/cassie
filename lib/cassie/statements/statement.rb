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
    require_relative 'statement/type_hinting'
    require_relative 'statement/idempotency'

    class Invalid < StandardError; end

    extend ::ActiveSupport::Concern

    included do
      include Preparation
      include TypeHinting
      include Idempotency

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
      Cassandra::Statements::Simple.new(*build_cql_and_params, type_hints, idempotent?)
    end

    # returns a CQL string with inline parameters, that
    # is representative of what could be executed in a CQL shell
    def to_cql
      if statement.respond_to?(:cql) && statement.respond_to?(:params)
        Cassie::Support::StatementParser.new(statement).to_cql
      else
        statement.to_s
      end
    end

    def logger
      Cassie::Statements.logger
    end

    def cql
      return @cql if defined?(@cql)
      ""
    end

    def params
      return @params if defined?(@params)
      nil
    end

    protected

    def build_cql_and_params
      if self.class.type
        send "build_#{self.class.type}_cql_and_params"
      end

      [cql, params]
    end

    private

    def source_eval(value, src=self)
      case value
      when Symbol
        src.send(value)
      else
        value
      end
    end
  end
end
